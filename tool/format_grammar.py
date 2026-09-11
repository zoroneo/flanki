#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flanki Grammar Formatter & Validator Pipeline
Tool for standardizing, formatting with Rich HTML, backing up, and validating
grammar JSON files in assets/data/grammar/
"""

import os
import sys
import re
import json
import shutil
import argparse
from typing import Dict, Any, List, Tuple

GRAMMAR_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "data", "grammar")

# Tag types to validate for balanced open/close pairs
TRACKED_TAGS = ['b', 'i', 'u', 'mark', 'code', 'span']

COLOR_GREEN = '#22c55e'
COLOR_RED = '#ef4444'
COLOR_AMBER = '#f59e0b'
COLOR_BLUE = '#3b82f6'

def validate_tags(text: str) -> List[str]:
    """Check that all tracked HTML tags are properly balanced in the text."""
    errors = []
    for tag in TRACKED_TAGS:
        opens = len(re.findall(rf'<{tag}(?:\s+[^>]*)?>', text, re.IGNORECASE))
        closes = len(re.findall(rf'</{tag}>', text, re.IGNORECASE))
        if opens != closes:
            errors.append(f"Tag <{tag}> mismatch: {opens} opened vs {closes} closed")
    return errors

def validate_unit_file(filepath: str) -> Tuple[bool, List[str]]:
    """Validate JSON format and tag balance in a unit file."""
    issues = []
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            raw = f.read()
        data = json.loads(raw)
    except Exception as e:
        return False, [f"JSON Parse Error: {e}"]

    # Check required fields
    for field in ['unitId', 'title', 'category', 'level', 'coreConcept', 'formulas', 'exercises']:
        if field not in data:
            issues.append(f"Missing required field: {field}")

    # Check tag balance across the entire raw JSON text
    tag_errors = validate_tags(raw)
    if tag_errors:
        issues.extend(tag_errors)

    return len(issues) == 0, issues

def backup_unit(unit_path: str) -> str:
    """Create a unit_XX.original.json backup if it doesn't already exist."""
    dir_name = os.path.dirname(unit_path)
    base_name = os.path.basename(unit_path)
    # e.g. unit_02.json -> unit_02.original.json
    orig_name = base_name.replace('.json', '.original.json')
    orig_path = os.path.join(dir_name, orig_name)

    if not os.path.exists(orig_path):
        shutil.copy2(unit_path, orig_path)
        print(f"  [BACKUP] Created {orig_name}")
    else:
        print(f"  [BACKUP] Existing {orig_name} preserved")
    return orig_path

def format_quotes_to_mark(text: str) -> str:
    """
    Wrap quoted terms 'keyword' in <mark>keyword</mark>,
    taking care NOT to break English contractions like haven't, didn't, was/were wasn't, won't, it's.
    """
    def replacer(match):
        content = match.group(1).strip()
        if not content or '<' in content or '>' in content:
            return match.group(0)
        return f"<mark>{content}</mark>"

    # Match 'text' where quote is not part of contraction
    pattern = r"(?<![a-zA-Z0-9])'([^'\n\r]+?)'(?![a-zA-Z0-9])"
    return re.sub(pattern, replacer, text)

def format_prompt(prompt: str, ex_type: str) -> str:
    """Format question prompts: underline blanks and bold [A]/[B]/[C]/[D]."""
    res = prompt
    if '<u>' not in res:
        res = re.sub(r'_{3,}', '<u>_______</u>', res)

    if ex_type == 'errorId':
        res = re.sub(r'\[([A-D])\]', r'<b>[\1]</b>', res)

    return res

def format_key_signal(text: str) -> str:
    """Format key signals with <mark> tags around quoted or key terms."""
    if '<mark>' in text:
        return text
    return format_quotes_to_mark(text)

def format_why_correct(text: str, correct_ans: str = '') -> str:
    """Format whyCorrect explanation with green emphasis for correct answer/form."""
    if 'color: #22c55e' in text:
        return text

    res = text
    if correct_ans:
        quoted_ans = f"'{correct_ans}'"
        if quoted_ans in res:
            res = res.replace(
                quoted_ans,
                f"<span style=\"color: {COLOR_GREEN}; font-weight: bold;\">'{correct_ans}'</span>"
            )

    return res

def format_distractor_breakdown(distractors: Dict[str, str]) -> Dict[str, str]:
    """Format distractor explanations with red/green badges."""
    new_dist = {}
    for opt, exp in distractors.items():
        if '<span' in exp:
            new_dist[opt] = exp
            continue

        res = exp
        if re.match(r'^(Sai)(\s|:|\.|\b)', res):
            res = re.sub(
                r'^(Sai)(\s|:|\.|\b)',
                f'<span style="color: {COLOR_RED}; font-weight: bold;">Sai</span>\\2',
                res,
                count=1
            )
        elif re.match(r'^(Không phù hợp|Không chuẩn xác|Kém tự nhiên|Không chính xác)(\s|:|\.|\b)', res):
            res = re.sub(
                r'^(Không phù hợp|Không chuẩn xác|Kém tự nhiên|Không chính xác)(\s|:|\.|\b)',
                f'<span style="color: {COLOR_RED}; font-weight: bold;">\\1</span>\\2',
                res,
                count=1
            )
        elif re.match(r'^(Đúng ngữ pháp|Đúng)(\s|:|\.|\b)', res):
            res = re.sub(
                r'^(Đúng ngữ pháp|Đúng)(\s|:|\.|\b)',
                f'<span style="color: {COLOR_GREEN}; font-weight: bold;">\\1</span>\\2',
                res,
                count=1
            )

        new_dist[opt] = res
    return new_dist

def format_formulas(formulas: Dict[str, str]) -> Dict[str, str]:
    """Standardize formula presentation with bold labels and <code> blocks."""
    new_forms = {}
    for key, formula_text in formulas.items():
        if '<code>' in formula_text:
            new_forms[key] = formula_text
            continue

        res = formula_text
        res = re.sub(r'\b(Khẳng định|Affirmative):\s*', r'<b>Khẳng định:</b> ', res)
        res = re.sub(r'\b(Phủ định|Negative):\s*', r'<b>Phủ định:</b> ', res)
        res = re.sub(r'\b(Nghi vấn|Question|Interrogative):\s*', r'<b>Nghi vấn:</b> ', res)

        if ' | ' in res:
            res = res.replace(' | ', '<br/>')
        elif '\n' in res:
            res = res.replace('\n', '<br/>')

        new_forms[key] = res
    return new_forms

def format_common_traps(traps: List[Dict[str, str]]) -> List[Dict[str, str]]:
    """Format common traps: highlight trap keywords and red/green examples."""
    new_traps = []
    for trap in traps:
        t = dict(trap)
        trap_title = t.get('trap', '')
        if '<span' not in trap_title and '<b' not in trap_title:
            trap_title = re.sub(r'^(Bẫy\s+\d+:?)\s*', r'<b>\1</b> ', trap_title)
            t['trap'] = trap_title

        new_traps.append(t)
    return new_traps

def format_unit_dict(data: Dict[str, Any]) -> Dict[str, Any]:
    """Apply all standard formatting rules to unit data."""
    if 'formulas' in data and isinstance(data['formulas'], dict):
        data['formulas'] = format_formulas(data['formulas'])

    if 'commonTraps' in data and isinstance(data['commonTraps'], list):
        data['commonTraps'] = format_common_traps(data['commonTraps'])

    if 'exercises' in data and isinstance(data['exercises'], list):
        for ex in data['exercises']:
            ex_type = ex.get('type', 'choice')
            correct = ex.get('correctAnswer', '')

            if 'prompt' in ex:
                ex['prompt'] = format_prompt(ex['prompt'], ex_type)

            if 'explanation' in ex and isinstance(ex['explanation'], dict):
                exp = ex['explanation']
                if 'keySignal' in exp:
                    exp['keySignal'] = format_key_signal(exp['keySignal'])
                if 'whyCorrect' in exp:
                    exp['whyCorrect'] = format_why_correct(exp['whyCorrect'], correct)
                if 'distractorBreakdown' in exp and isinstance(exp['distractorBreakdown'], dict):
                    exp['distractorBreakdown'] = format_distractor_breakdown(exp['distractorBreakdown'])

    return data

def process_unit_file(filepath: str, dry_run: bool = False, no_backup: bool = False) -> bool:
    """Format and validate a single unit file."""
    base = os.path.basename(filepath)
    print(f"\nProcessing {base}...")

    if not dry_run and not no_backup:
        backup_unit(filepath)

    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    formatted_data = format_unit_dict(data)
    output_str = json.dumps(formatted_data, ensure_ascii=False, indent=2) + "\n"

    tag_errors = validate_tags(output_str)
    if tag_errors:
        print(f"  [ERROR] Tag validation failed for {base}:")
        for err in tag_errors:
            print(f"    - {err}")
        return False

    if dry_run:
        print(f"  [DRY-RUN] Validation passed. No changes written.")
    else:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(output_str)
        print(f"  [SUCCESS] Formatted & saved {base}")

    return True

def main():
    sys.stdout.reconfigure(encoding='utf-8')
    parser = argparse.ArgumentParser(description="Flanki Grammar Unit Formatter & Linter")
    parser.add_argument('--units', type=str, help="Comma-separated unit numbers, e.g. 2,3,4,5,6")
    parser.add_argument('--range', nargs=2, type=int, metavar=('START', 'END'), help="Range of units, e.g. --range 2 6")
    parser.add_argument('--all', action='store_true', help="Process all units 01 to 36")
    parser.add_argument('--verify', action='store_true', help="Only verify and validate existing files without changes")
    parser.add_argument('--dry-run', action='store_true', help="Preview formatting and validate without writing")
    parser.add_argument('--no-backup', action='store_true', help="Do not create backup files")

    args = parser.parse_args()

    target_nums = []
    if args.units:
        target_nums = [int(u.strip()) for u in args.units.split(',') if u.strip().isdigit()]
    elif args.range:
        target_nums = list(range(args.range[0], args.range[1] + 1))
    elif args.all:
        target_nums = list(range(1, 37))
    elif not args.verify:
        print("Please specify --units, --range, --all, or --verify. Run with -h for help.")
        sys.exit(1)

    if args.verify:
        print("=== VERIFYING ALL GRAMMAR UNITS ===")
        all_files = sorted([
            os.path.join(GRAMMAR_DIR, f)
            for f in os.listdir(GRAMMAR_DIR)
            if re.match(r'^unit_\d{2}\.json$', f)
        ])
        total = len(all_files)
        passed = 0
        for f in all_files:
            ok, issues = validate_unit_file(f)
            base = os.path.basename(f)
            if ok:
                passed += 1
                print(f"  [PASS] {base}")
            else:
                print(f"  [FAIL] {base}:")
                for iss in issues:
                    print(f"    - {iss}")
        print(f"\nResult: {passed}/{total} units valid.")
        sys.exit(0 if passed == total else 1)

    success_count = 0
    for num in target_nums:
        fname = f"unit_{num:02d}.json"
        fpath = os.path.join(GRAMMAR_DIR, fname)
        if not os.path.exists(fpath):
            print(f"  [WARNING] File not found: {fname}")
            continue

        if process_unit_file(fpath, dry_run=args.dry_run, no_backup=args.no_backup):
            success_count += 1

    print(f"\nDone. Successfully processed {success_count}/{len(target_nums)} units.")

if __name__ == '__main__':
    main()
