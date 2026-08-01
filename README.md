# FCF syllabus

This repository contains the Quarto book version of the course syllabus for
Fundamentos cuantitativos en finanzas FCF.

## Publishing workflow

- Edit the active `.qmd` source files in the project root.
- Preview or verify the complete book locally with Quarto:

```powershell
quarto render
```

- The rendered website is written to `docs/`.
- A push to `main` runs `.github/workflows/publish.yml`.
- GitHub Actions installs Quarto, renders the complete book, checks the output,
  and deploys `docs/` to GitHub Pages.
- The automated render does not require R, R packages, or Chocolatey.
- The local `docs/` directory is generated output and is not tracked by Git.
  Rendering locally recreates or updates it without changing the repository.
- The homepage `Edition` value is the first seven characters of the Git commit
  SHA used for the render.

## Active structure

The active book structure is defined in `_quarto.yml`.

Main source chapters:

- `index.qmd`
- `welcome.qmd`
- `course-overview.qmd`
- `tools-data-science.qmd`
- `course-activities.qmd`
- `evaluation.qmd`
- `rubrics.qmd`
- `course-policies.qmd`
- `checklist.qmd`
- `schedule.qmd`
- `learning-resources.qmd`
- `internet-resources.qmd`
- `references.qmd`

Historical files and legacy notes are kept in `archive/`.

## Reusing the syllabus

The course and semester values that appear in more than one place are defined
in the `course` block near the top of `_quarto.yml`:

- course code and title
- academic term and review status
- room, meeting days, meeting time, and class Zoom information

Quarto reuses those values in the book title, subtitle, footer, and schedule.
When adapting this repository for another course, update that block first.
Then revise the course-specific material in `course-overview.qmd`,
`schedule.qmd`, and the bibliography entries used by that course. Do not edit
the generated files in `docs/`.
