# Contributing Guide

Thanks for helping shape Remote Linux Lab. This project doubles as a portfolio artifact, so every contribution should reinforce clarity, reproducibility, and beginner-friendly explanations.

## Quick Start Checklist

1. Fork the repository and create a feature branch named `feature/<short-description>`.
2. Run `shellcheck scripts/*.sh` locally before opening a pull request.
3. Execute any touched scripts with `--help` to ensure usage text and exit codes read well.
4. Capture a sample report or metric artifact and attach it to the PR if your change affects output.

## Commit Style

- Use conventional-style prefixes when possible: `feat:`, `fix:`, `docs:`, `ci:`, `refactor:`.
- Keep commits focused; split functional changes from documentation refreshes when practical.

## Pull Request Expectations

- Fill out the PR template, including the _Evidence_ section (link to generated reports/logs).
- Note any manual testing performed and residual risks.
- Request review from @prashantbhardwaj or tag `#devops-mentees` if pairing.

## Issue Templates

- Use the **Scenario Proposal** template to suggest new guided scenarios.
- Use the **Bug Report** template when a script misbehaves.
- Provide reproduction steps that work inside the Segfault sandbox or the Docker lab container.

## Coding Standards

- Bash should target POSIX where possible but may rely on Bash 5 features when they improve readability.
- Comment only where intent is non-obvious; prefer concise docstrings at the top of scripts.
- Default to markdown outputs for reports so recruiters can skim them without tooling.

## Documentation Standards

- Update the README whenever you add noteworthy automation, scenarios, or visuals.
- Store screenshots and GIFs in `docs/media/` and reference them with descriptive captions.

Thank you for contributing and helping the project stay portfolio-ready.
