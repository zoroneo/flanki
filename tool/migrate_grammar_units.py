#!/usr/bin/env python3
"""
tool/migrate_grammar_units.py

Automated migration pipeline to standardize grammar theory data across units 02 to 36
to match the high-quality, rich HTML format established in unit_01.json.

Features:
- difflib.SequenceMatcher to accurately underline (<u>) errors and corrections in commonTraps.
- Syntax wrapping (<code>) and label bolding (<b>) in formulas.
- Semantic HTML structuring for coreConcept (numbered headings, bullet points, italics examples, &rarr;, &mdash;).
- Polishing extraGuides into structured HTML lists.
- 100% preservation of all 360 exercises, IDs, options, and keys.
"""

import argparse
import difflib
import glob
import json
import os
import re
import sys


def diff_and_underline(wrong, right):
    """Accurately underlines the diff between exampleWrong and exampleRight using word-level diffing."""
    # Strip existing <u> tags to ensure idempotency when re-running
    wrong = wrong.replace('<u>', '').replace('</u>', '')
    right = right.replace('<u>', '').replace('</u>', '')

    w_words = wrong.split()
    r_words = right.split()

    s = difflib.SequenceMatcher(None, w_words, r_words)
    opcodes = s.get_opcodes()

    w_underlined = [False] * len(w_words)
    r_underlined = [False] * len(r_words)

    for tag, i1, i2, j1, j2 in opcodes:
        if tag == 'replace':
            for idx in range(i1, i2):
                w_underlined[idx] = True
            for idx in range(j1, j2):
                r_underlined[idx] = True
        elif tag == 'delete':
            # Word deleted from wrong -> anchor with adjacent word in both
            for idx in range(i1, i2):
                w_underlined[idx] = True
            if i2 < len(w_words) and j1 < len(r_words):
                w_underlined[i2] = True
                r_underlined[j1] = True
            elif i1 > 0 and j1 > 0:
                w_underlined[i1 - 1] = True
                r_underlined[j1 - 1] = True
        elif tag == 'insert':
            # Word inserted into right -> anchor with adjacent word in both
            for idx in range(j1, j2):
                r_underlined[idx] = True
            if i1 < len(w_words) and j2 < len(r_words):
                w_underlined[i1] = True
                r_underlined[j2] = True
            elif i1 > 0 and j1 > 0:
                w_underlined[i1 - 1] = True
                r_underlined[j1 - 1] = True

    def build_string(words, flags):
        res = []
        in_u = False
        for w, u in zip(words, flags):
            if u and not in_u:
                res.append(f"<u>{w}")
                in_u = True
            elif not u and in_u:
                res[-1] = f"{res[-1]}</u>"
                res.append(w)
                in_u = False
            else:
                res.append(w)
        if in_u:
            res[-1] = f"{res[-1]}</u>"
        return " ".join(res)

    return build_string(w_words, w_underlined), build_string(r_words, r_underlined)


def format_trap_note(note):
    """Wraps grammatical keywords and syntax structures in <code> and <b>."""
    if '<code>' in note:
        return note

    # Replace arrows
    note = note.replace(' -> ', ' &rarr; ').replace('->', ' &rarr; ')

    # Wrap syntax expressions like 'S + was/were + V-ing' in <code>
    note = re.sub(r"'(S\s*\+[^']+)'", r"<code>\1</code>", note)
    note = re.sub(r"'(When\s*\+[^']+)'", r"<code>\1</code>", note)
    note = re.sub(r"'(While\s*\+[^']+)'", r"<code>\1</code>", note)

    # Wrap quoted grammar keywords 'word' -> <code>word</code>
    keywords = [
        'always', 'constantly', 'forever', 'currently', 'at the moment', 'now',
        'when', 'while', 'as', 'as soon as', 'until', 'by the time', 'used to',
        'would', 'be used to', 'get used to', 'since', 'for', 'already', 'yet',
        'just', 'ever', 'never', 'immediately', 'promptly', 'at once', 'right away',
        'tomorrow', 'next week', 'yesterday', 'ago', 'last night'
    ]
    for kw in keywords:
        pattern = re.compile(rf"['\"]({re.escape(kw)})['\"]", re.IGNORECASE)
        note = pattern.sub(r"<code>\1</code>", note)

    return note


def format_common_traps(traps):
    """Standardizes commonTraps with accurate <u> diffs, bold titles, and styled notes."""
    new_traps = []
    for trap in traps:
        t = dict(trap)
        w, r = diff_and_underline(t.get('exampleWrong', ''), t.get('exampleRight', ''))
        t['exampleWrong'] = w
        t['exampleRight'] = r
        t['note'] = format_trap_note(t.get('note', ''))

        # Standardize trap title format
        title = t.get('trap', '')
        if not title.startswith('<b>') and 'Bẫy ' in title:
            title = re.sub(r'^(Bẫy\s*\d+:?)\s*', r'<b>\1</b> ', title)
        t['trap'] = title

        new_traps.append(t)
    return new_traps


def format_core_concept(text, unit_id='', title=''):
    """Transforms unformatted plain text coreConcept into rich semantic HTML matching Unit 01 standard."""
    if unit_id == 'unit-01-present-simple-vs-continuous':
        return text  # Already the gold standard reference

    # Normalize newlines
    raw = text.replace('<br/>', '\n').replace('<br>', '\n')
    lines = [l.strip() for l in raw.split('\n') if l.strip()]
    processed_lines = []

    for idx, line in enumerate(lines):
        line_clean = re.sub(r'</?[biu]>', '', line).strip()

        # 1. Lead takeaway sentence (idx == 0)
        if idx == 0:
            # Topic bolding: khi lựa chọn giữa A và B
            m = re.match(
                r'^(.*?khi lựa chọn giữa\s+)(.+?)\s+và\s+(.+?)(\s+(?:không|dựa|nằm|nhằm).*)$',
                line_clean,
                re.IGNORECASE
            )
            if m:
                intro = m.group(1)
                t1 = re.sub(r'\s*\([^)]*\)', '', m.group(2)).strip()
                t2 = re.sub(r'\s*\([^)]*\)', '', m.group(3)).strip()
                rest = m.group(4)
                line_clean = f"{intro}<b>{t1}</b> và <b>{t2}</b>{rest}"
            elif 'khi sử dụng' in line_clean:
                m_use = re.match(
                    r'^(.*?khi sử dụng\s+)(.+?)(\s+(?:không|dựa|nằm|hoàn toàn|nhằm).*)$',
                    line_clean,
                    re.IGNORECASE
                )
                if m_use:
                    intro = m_use.group(1)
                    t1 = re.sub(r'\s*\([^)]*\)', '', m_use.group(2)).strip()
                    rest = m_use.group(3)
                    line_clean = f"{intro}<b>{t1}</b>{rest}"

            # Lowercase shouting uppercase mindset after anchor phrases
            def lower_caps_mindset(m_lead):
                prefix = m_lead.group(1)
                caps_part = m_lead.group(2).strip()
                return f"{prefix} <b>{caps_part.lower()}</b>:"

            anchor_pattern = (
                r'(mà dựa vào|mà nằm ở|dựa vào|nằm ở|hoàn toàn không phải để.*?, mà nằm ở|'
                r'không nằm ở.*?, mà nằm ở|không đơn thuần là.*?, mà nằm ở|'
                r'không nhằm.*?, mà phản ánh|không nhằm.*?, mà nằm ở)\s+'
                r'([A-ZÀ-Ỹ0-9\s/&().,\-–—]+):?$'
            )
            line_clean = re.sub(anchor_pattern, lower_caps_mindset, line_clean)
            processed_lines.append(line_clean)
            continue

        # 2. Numbered section heading: e.g. 1. Quá khứ đơn (Completed & Terminated - Khối sự kiện...)
        m_num = re.match(r'^(\d+\.\s*)([^(:\n]+)(?:\s*\((.*?)\))?:?$', line_clean)
        if m_num:
            num = m_num.group(1)
            name = m_num.group(2).strip()
            parens = m_num.group(3)
            if parens:
                if ' - ' in parens or ' &mdash; ' in parens:
                    split_char = ' &mdash; ' if ' &mdash; ' in parens else ' - '
                    sub, note = parens.split(split_char, 1)
                    line_clean = f"{num}<b>{name}</b> (<b>{sub.strip()}</b> &mdash; {note.strip()}):"
                else:
                    line_clean = f"{num}<b>{name}</b> (<b>{parens.strip()}</b>):"
            else:
                line_clean = f"{num}<b>{name}</b>:"
            processed_lines.append(line_clean)
            continue

        # 3. Examples: - Ví dụ: '...' -> ... or Ví dụ: '...' (...)
        if line_clean.startswith('- Ví dụ:') or line_clean.startswith('Ví dụ:'):
            ex_body = re.sub(r'^-?\s*Ví dụ:\s*', '', line_clean)
            m_quote = re.search(r"['\"](.*?)['\"]\s*(?:(?:\((.*?)\)|&rarr;|->\s*(.*?))\.?)?$", ex_body)
            if m_quote:
                quote = m_quote.group(1)
                expl = m_quote.group(2) or m_quote.group(3) or ''
                if expl:
                    line_clean = f"- <i>Ví dụ:</i> '<i>{quote}</i>' &rarr; {expl.strip()}"
                else:
                    line_clean = f"- <i>Ví dụ:</i> '<i>{quote}</i>'"
            else:
                line_clean = f"- <i>Ví dụ:</i> {ex_body}"
            processed_lines.append(line_clean)
            continue

        # 4. Bullets: - ...
        if line_clean.startswith('- '):
            body = line_clean[2:].strip()
            body = body.replace(' -> ', ' &rarr; ').replace('->', ' &rarr; ')
            body = body.replace(' - ', ' &mdash; ')

            # Contrast item: Past Simple = ... or Past Simple: ...
            m_comp = re.match(r'^([A-Za-z\s]+)\s*(=|:)\s*(.*)$', body)
            if m_comp and len(m_comp.group(1).strip().split()) <= 4 and not m_comp.group(1).startswith('Ví dụ'):
                c_name = m_comp.group(1).strip()
                c_desc = m_comp.group(3).strip()
                m_sub = re.match(r'^(.*?)\s*\((.*?)\):\s*(.*)$', c_desc)
                if m_sub:
                    c_desc = f"{m_sub.group(1).strip()} (<i>{m_sub.group(2).strip()}</i>) &mdash; {m_sub.group(3).strip()}"
                body = f"<b>{c_name}:</b> {c_desc}"
            else:
                # Specific cleanups for shouting uppercase terms
                body = re.sub(r'KẾT THÚC 100%', '<b>kết thúc 100%</b>', body)
                body = re.sub(r'CHẤM DỨT 100%', '<b>chấm dứt 100%</b>', body)
                body = re.sub(r'ĐANG DIỄN RA, CHƯA KẾT THÚC', '<b>đang diễn ra, chưa kết thúc</b>', body)
                body = re.sub(r"'gói sự kiện đã hoàn tất'", "<b>'gói sự kiện đã hoàn tất'</b>", body)
                body = re.sub(r"'phóng to'", "<b>'phóng to'</b>", body)
                body = re.sub(r'bức tranh phông nền', '<b>bức tranh phông nền</b>', body)
                body = re.sub(r'sự thật lịch sử', '<b>sự thật lịch sử</b>', body)
                body = re.sub(r'tính diễn tiến', '<b>tính diễn tiến</b>', body)

                # Format English parenthetical terms into italics: (packaged event) -> (<i>packaged event</i>)
                body = re.sub(r'\((?!\s*<i\s*>)([A-Za-z\s/–-]+)\)', r'(<i>\1</i>)', body)

                def bold_selective_caps(match):
                    word = match.group(0)
                    if word in ['KHÔNG', 'BẮT BUỘC', 'TUYỆT ĐỐI']:
                        return f"<b>{word}</b>"
                    return word

                body = re.sub(r'\b[A-ZÀ-Ỹ]{3,}\b', bold_selective_caps, body)

            line_clean = f"- {body}"
            processed_lines.append(line_clean)
            continue

        # 5. Sub-bullets (+ ...)
        if line_clean.startswith('+ '):
            body = line_clean[2:].strip().replace(' -> ', ' &rarr; ').replace('->', ' &rarr; ')
            body = body.replace(' - ', ' &mdash; ')
            if '+' in body or 'S +' in body or 'was/were' in body:
                line_clean = f"&nbsp;&nbsp;• <code>{body}</code>"
            else:
                line_clean = f"&nbsp;&nbsp;• {body}"
            processed_lines.append(line_clean)
            continue

        # Fallback
        line_clean = line_clean.replace(' -> ', ' &rarr; ').replace('->', ' &rarr; ')
        line_clean = line_clean.replace(' - ', ' &mdash; ')
        processed_lines.append(line_clean)

    # Join lines: Numbered items get <br/><br/> before them; bullets get <br/>
    out = []
    for idx, pl in enumerate(processed_lines):
        if re.match(r'^\d+\.\s*<b>', pl):
            out.append(f"<br/><br/>{pl}")
        elif pl.startswith('- ') or pl.startswith('&nbsp;&nbsp;•'):
            out.append(f"<br/>{pl}")
        else:
            if idx > 0 and not out[-1].endswith('<br/><br/>'):
                out.append(f"<br/><br/>{pl}")
            else:
                out.append(pl)

    return "".join(out)


def format_formula_value(text):
    """Wraps grammatical formulas in <code> and bolds standard labels."""
    if '<code>' in text:
        return text

    # Leave markdown tables for CardContentParser
    if text.strip().startswith('|') or '\n|' in text:
        return text

    lines = text.split('<br/>') if '<br/>' in text else text.split('\n')
    processed = []

    for line in lines:
        l = line.strip()
        if not l:
            continue

        # Pattern 1: <b>Khẳng định:</b> S + ...
        m_bold = re.match(r'^(<b>.*?:</b>)\s*(.*)$', l)
        if m_bold:
            label = m_bold.group(1)
            body = m_bold.group(2).strip()
            if body and not body.startswith('<code>'):
                l = f"{label} <code>{body}</code>"
            processed.append(l)
            continue

        # Pattern 2: - Khẳng định: S + ... or Khẳng định: S + ...
        m_dash = re.match(r'^(?:-\s*)?([A-ZÀ-Ỹa-zà-ỹ\s]+:)\s*(.*)$', l)
        if m_dash and any(k in m_dash.group(1).lower() for k in [
            'khẳng định', 'phủ định', 'nghi vấn', 'công thức', 'chủ động', 'bị động'
        ]):
            label = m_dash.group(1).strip()
            body = m_dash.group(2).strip()
            if body and not body.startswith('<code>'):
                l = f"<b>{label}</b> <code>{body}</code>"
            else:
                l = f"<b>{label}</b> {body}"
            processed.append(l)
            continue

        # Pattern 3: 1. Present Simple: ... or 1. Khẳng định: ...
        m_num = re.match(r'^(\d+\.\s+)(.*?):\s*(.*)$', l)
        if m_num:
            num = m_num.group(1)
            label = m_num.group(2).strip()
            body = m_num.group(3).strip()
            if body and ('+' in body or 'S +' in body or 'V' in body):
                l = f"{num}<b>{label}:</b> <code>{body}</code>"
            else:
                l = f"{num}<b>{label}:</b> {body}"
            processed.append(l)
            continue

        processed.append(l)

    return '<br/>'.join(processed)


def format_formulas(formulas_dict):
    """Transforms all formula entries in a unit."""
    new_formulas = {}
    for k, v in formulas_dict.items():
        new_formulas[k] = format_formula_value(v)
    return new_formulas


def format_extra_guide_value(text):
    """Transforms plain text extraGuides into clean structured HTML lists."""
    if '<br/>' in text and ('<b>' in text or '•' in text):
        return text

    lines = text.strip().split('\n')
    processed = []

    for line in lines:
        l = line.strip()
        if not l:
            continue

        # Main all-caps heading e.g. QUY TẮC KẾT HỢP VỚI LIÊN TỪ WHEN, WHILE VÀ AS:
        if re.match(r'^[A-ZÀ-Ỹ\s,–\-\(\):]{10,}$', l):
            l = f"<b>{l}</b>"
        # Numbered item e.g. 1. Hành động đang diễn ra... (Interrupted Action):
        elif re.match(r'^\d+\.\s+', l):
            m_num = re.match(r'^(\d+\.\s+)(.*?)(?:\s*\((.*?)\))?:?$', l)
            if m_num:
                num = m_num.group(1)
                title = m_num.group(2).strip()
                parens = m_num.group(3)
                if parens:
                    l = f"{num}<b>{title}</b> (<b>{parens.strip()}</b>):"
                else:
                    l = f"{num}<b>{title}</b>:"
        elif l.startswith('- Ví dụ:') or l.startswith('Ví dụ:'):
            ex_body = re.sub(r'^-?\s*Ví dụ:\s*', '', l)
            l = f"- <i>Ví dụ:</i> {ex_body}"
        elif l.startswith('- '):
            body = l[2:].strip().replace(' -> ', ' &rarr; ').replace('->', ' &rarr; ')
            l = f"• {body}"
        elif l.startswith('+ '):
            body = l[2:].strip().replace(' -> ', ' &rarr; ').replace('->', ' &rarr; ')
            if '+' in body or 'was/were' in body:
                l = f"&nbsp;&nbsp;↳ <code>{body}</code>"
            else:
                l = f"&nbsp;&nbsp;↳ {body}"

        processed.append(l)

    # Join with <br/>
    out = []
    for idx, pl in enumerate(processed):
        if pl.startswith('<b>') or re.match(r'^\d+\.\s+<b>', pl):
            out.append(f"<br/><br/>{pl}")
        elif pl.startswith('•') or pl.startswith('- ') or pl.startswith('&nbsp;&nbsp;↳'):
            out.append(f"<br/>{pl}")
        else:
            if idx > 0 and not out[-1].endswith('<br/><br/>'):
                out.append(f"<br/><br/>{pl}")
            else:
                out.append(pl)

    res = "".join(out)
    if res.startswith('<br/><br/>'):
        res = res[10:]
    return res


def migrate_unit(data):
    """Migrates a single unit dictionary, returning the updated dictionary."""
    updated = dict(data)
    unit_id = updated.get('unitId', '')
    title = updated.get('title', '')

    # 1. coreConcept
    updated['coreConcept'] = format_core_concept(
        updated.get('coreConcept', ''),
        unit_id=unit_id,
        title=title
    )

    # 2. formulas
    if 'formulas' in updated:
        updated['formulas'] = format_formulas(updated['formulas'])

    # 3. commonTraps
    if 'commonTraps' in updated:
        updated['commonTraps'] = format_common_traps(updated['commonTraps'])

    # 4. extraGuides
    base_keys = {
        'unitId', 'title', 'category', 'level', 'coreConcept',
        'formulas', 'commonTraps', 'exercises'
    }
    for k, v in list(updated.items()):
        if k not in base_keys and isinstance(v, str):
            updated[k] = format_extra_guide_value(v)

    # 5. exercises: 100% PRESERVED AS IS
    return updated


def main():
    parser = argparse.ArgumentParser(description="Migrate grammar units to rich HTML format.")
    parser.add_argument('--dry-run', action='store_true', help="Check transformations without writing files.")
    parser.add_argument('--unit', type=int, help="Migrate a specific unit number (e.g. 2).")
    parser.add_argument('--all', action='store_true', help="Migrate all units from 02 to 36.")
    args = parser.parse_args()

    grammar_dir = 'assets/data/grammar'
    if not os.path.exists(grammar_dir):
        print(f"Error: {grammar_dir} does not exist.")
        sys.exit(1)

    if args.unit:
        target_files = [f"{grammar_dir}/unit_{args.unit:02d}.json"]
    elif args.all or args.dry_run:
        # Default or all: units 02 to 36 (skip unit 01)
        all_files = sorted(glob.glob(f"{grammar_dir}/unit_*.json"))
        target_files = [f for f in all_files if not f.endswith('unit_01.json')]
    else:
        print("Please specify --dry-run, --unit <N>, or --all.")
        sys.exit(0)

    print(f"Processing {len(target_files)} file(s)... (Dry-run: {args.dry_run})")

    modified_count = 0
    underlined_traps_total = 0

    for filepath in target_files:
        with open(filepath, 'r', encoding='utf-8') as f:
            original = json.load(f)

        migrated = migrate_unit(original)

        # Count underlined traps
        traps = migrated.get('commonTraps', [])
        underlined_traps = sum(1 for t in traps if '<u>' in t.get('exampleWrong', ''))
        underlined_traps_total += underlined_traps

        # Verify exercises untouched
        orig_ex = original.get('exercises', [])
        mig_ex = migrated.get('exercises', [])
        assert len(orig_ex) == len(mig_ex), f"Exercise count mismatch in {filepath}!"
        assert [e['id'] for e in orig_ex] == [e['id'] for e in mig_ex], f"Exercise IDs mismatch in {filepath}!"

        if not args.dry_run:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(migrated, f, ensure_ascii=False, indent=2)
                f.write('\n')

        modified_count += 1
        unit_name = os.path.basename(filepath)
        print(f"  [OK] {unit_name}: {underlined_traps}/{len(traps)} traps underlined, exercises intact.")

    print(f"\nDone! Processed {modified_count} unit(s). Total underlined traps: {underlined_traps_total}.")


if __name__ == '__main__':
    main()
