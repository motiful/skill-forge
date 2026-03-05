# Templates

## README.md Template

```markdown
# <skill-name>

> <description from SKILL.md frontmatter>

## What This Is

An [Agent Skills](https://agentskills.io) compatible skill that <expanded description>.

## Install

```bash
git clone https://github.com/<org>/<skill-name> ~/skills/<skill-name>
```

Then register on your platform:

| Platform | Command |
|----------|---------|
| Claude Code | `ln -s ~/skills/<skill-name>/skill ~/.claude/skills/<skill-name>` |
| Cursor | `ln -s ~/skills/<skill-name>/skill ~/.cursor/skills/<skill-name>` |
| Other | Symlink or copy `skill/` to your agent's skills directory |

## What's Inside

```
skill/
├── SKILL.md          — Main skill instructions
├── references/       — Detailed reference docs (loaded on demand)
└── scripts/          — Executable utilities (if any)
```

## License

MIT
```

## LICENSE Template (MIT)

```
MIT License

Copyright (c) <year> <author>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## .gitignore Template

```
.DS_Store
*.skill
node_modules/
dist/
.env
```
