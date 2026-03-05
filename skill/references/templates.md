# Templates

## README.md Template

```markdown
# <skill-name>

> <description from SKILL.md frontmatter>

## What This Is

A [Claude Code](https://claude.com/claude-code) skill that <expanded description>.

## Install

### Claude Code

```bash
# Clone the repo
git clone https://github.com/<org>/<skill-name> ~/motifpool/<skill-name>

# Register as a global skill
ln -s ~/motifpool/<skill-name>/skill ~/.claude/skills/<skill-name>
```

### Other AI Tools

The skill's knowledge is in `skill/SKILL.md` and `skill/references/`. You can adapt these files for your tool's format (e.g., append to AGENTS.md, include in system prompt).

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
