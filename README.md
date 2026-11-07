# Set Up LangGraph and LangSmith Studio on Windows

A practical guide by **Victor Pereira** to preparing a local Windows development environment for the LangChain Academy **Introduction to LangGraph** course.

**This repository is a guide and a small collection of configuration examples, not an installer.** Run the steps deliberately in your own environment. It does not install software, create accounts, provision resources, or deploy an application automatically.

## What this guide covers

- Clone or download the official course notebooks.
- Create and activate a Python virtual environment in Windows PowerShell.
- Install course dependencies and choose a Jupyter interface.
- Configure LangSmith, OpenAI, and optionally Tavily credentials locally.
- Run the Module 1 development server and connect LangSmith Studio.

The demonstrated endpoint is **Module 1's `simple_graph` visible in Studio**. Executing graphs, verifying model responses and traces, and exploring state and memory are follow-up work. Jupyter and Tavily commands are reference setup instructions, not evidence of completed notebook or search tests.

## LangGraph versus LangSmith

**LangGraph** is the framework and runtime for stateful agent workflows. **LangSmith** provides tools for observability, evaluation, and deployment. **LangSmith Studio**, formerly LangGraph Studio, is the visual interface used here to inspect and test agents.

The local Agent Server and course code run on your computer. The Studio web interface is hosted at `smith.langchain.com` and connects to that server. This guide does not install the entire LangSmith platform locally.

## Files in this repository

| File | Purpose |
| --- | --- |
| `introduction-to-langgraph-practical-guide.html` | Self-contained responsive article, with embedded illustrations and screenshots |
| `examples/project-root.env.example` | Placeholder configuration for the course repository root |
| `examples/studio.env.example` | Placeholder configuration to merge with a module's Studio template |
| `creating_env_by_module-powershell.ps1` | Original PowerShell adaptation for preparing Modules 1–5; review limitations below |
| `.gitignore` | Excludes local secrets, virtual environments, and runtime output |

The course notebooks are **not bundled**. Obtain them from their official repository. These example files belong in the separate course checkout as described below; this documentation repository is not itself a runnable LangGraph application.

## 1. Get the course files

Install Python, Git, and use Windows PowerShell. Then run:

```powershell
python3 --version
git clone https://github.com/langchain-ai/langchain-academy.git
cd langchain-academy
```

Alternatively, [download the course ZIP](https://github.com/langchain-ai/langchain-academy/archive/refs/heads/main.zip), extract it, and open PowerShell in `langchain-academy-main`.

Python command names vary by Windows installation. If `python3` is unavailable, use the installed `python` or `py` command after checking its version. Check the course's current interpreter requirements and package compatibility when reproducing the lab.

## 2. Create and activate the environment

Run from the **course repository root**, not this documentation repository:

```powershell
python3 -m venv lc-academy-env
ls
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
.\lc-academy-env\Scripts\Activate.ps1
python -m pip install -r requirements.txt
```

Confirm the execution-policy prompt if shown. `-Scope Process` limits this policy change to the current session; organization policies can override it. Activation adds `(lc-academy-env)` to the prompt. Unix's `source .../bin/activate` command is replaced by `Scripts\Activate.ps1` in PowerShell.

## 3. Install a notebook interface

With the environment active, choose **JupyterLab or Notebook**:

```powershell
python -m pip install jupyterlab
jupyter lab
```

Or:

```powershell
python -m pip install notebook
jupyter notebook
```

Run one server at a time in a terminal. Stop it with `Ctrl+C` and follow any confirmation prompt before entering further commands there.

Optional, for notebook dashboards:

```powershell
python -m pip install voila
voila
# Or: voila your-notebook.ipynb
```

Homebrew is an option for macOS/Linux. Windows alternatives include **WinGet, Chocolatey, and Scoop**. WinGet is Microsoft's package manager, delivered through App Installer on Windows 11 and modern Windows 10 installations. It is not required for these pip commands.

```powershell
winget --version
```

## 4. Create accounts and configure the root .env

Create a [LangSmith account and API key](https://docs.langchain.com/langsmith/create-account-api-key). For OpenAI examples, create a key in the [OpenAI developer platform](https://platform.openai.com/). Check billing and available credits; model requests can incur usage charges. Another provider can be used with the appropriate integration, credentials, and changes to model calls.

[Tavily](https://tavily.com/) is optional for today's setup. Some Module 4 lessons use its web search API. Check its current free-plan terms.

From the **course repository root**:

```powershell
notepad .env
```

Use `examples/project-root.env.example` from this repository as a reference. Save as `.env`, not `.env.txt`, **beside** `lc-academy-env`, not inside it:

```dotenv
LANGSMITH_API_KEY="your-langsmith-api-key"
LANGSMITH_TRACING=true
LANGSMITH_PROJECT="langchain-academy"
# EU instance only; uncomment if applicable:
# LANGSMITH_ENDPOINT=https://eu.api.smith.langchain.com
OPENAI_API_KEY="your-openai-api-key"
# Optional for later lessons:
TAVILY_API_KEY="your-tavily-api-key"
```

Current LangSmith documentation uses `LANGSMITH_TRACING=true`; the supplied course notes used `LANGSMITH_TRACING_V2=true`. This example follows the course's project-based workflow.

Saving a `.env` file does **not** populate PowerShell automatically. For notebooks, load it before creating clients, with `python-dotenv` installed:

```python
from dotenv import load_dotenv

load_dotenv("../.env")  # When the working directory is module-1 or module-2
```

Use `load_dotenv(".env")` if the working directory is the course repository root. A notebook loading variables does not modify a separate PowerShell session.

## 5. Prepare Module 1 Studio configuration

With the virtual environment active, start at the course repository root:

```powershell
python -m pip install "langgraph-cli[inmem]"
cd module-1/studio
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
notepad .env
```

Merge the necessary placeholder settings from `examples/studio.env.example`, replacing values **locally**. Preserve any additional entries in the course template, and avoid duplicate variables.

Module 1's supplied `langgraph.json` points to `./.env`, so **`module-1/studio/.env` is distinct from the root `.env`**. The root file does not automatically satisfy this configuration path.

### Optional alternative: prepare multiple modules

The included `creating_env_by_module-powershell.ps1` is the author's PowerShell adaptation of the course Bash loop. Copy it to the **course repository root** if you want to use it, then review it before running:

```powershell
.\creating_env_by_module-powershell.ps1
```

Important behavior:

- Processes **Modules 1–5**, not Module 6.
- Uses `Copy-Item -Force`, overwriting existing module `.env` files with their templates. Back up custom settings first.
- Appends `OPENAI_API_KEY` from the current PowerShell process to each module.
- Appends `TAVILY_API_KEY` to Module 4.
- Does **not** load the root `.env` or add the LangSmith key.
- Unset PowerShell variables produce empty values; templates may also contain duplicate entries after appending.

Check variables without printing secrets:

```powershell
if ([string]::IsNullOrWhiteSpace($env:OPENAI_API_KEY)) {
    throw "OPENAI_API_KEY is not set in this PowerShell session."
}
if ([string]::IsNullOrWhiteSpace($env:TAVILY_API_KEY)) {
    throw "TAVILY_API_KEY is not set in this PowerShell session."
}
```

Set or load these variables locally using your preferred method. If they are not already available, the **manual Module 1 configuration above is sufficient** and avoids this helper. Do not run the helper after manual configuration unless you intend to replace those files.

## 6. Start Module 1 and connect Studio

Starting at the course repository root with the environment active:

```powershell
pwd
ls
cd module-1/studio
langgraph dev
```

If already inside `module-1/studio`, run only `langgraph dev`. This development workflow does not require Docker.

Default addresses printed by the server:

| Service | Address |
| --- | --- |
| Local Agent Server | `http://127.0.0.1:2024` |
| Studio | `https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024` |
| Local API documentation | `http://127.0.0.1:2024/docs` |

Use the actual addresses printed if they differ. Keep the terminal running, open the Studio URL, and select `simple_graph`. The author's screenshots show the local-server connection and graph visualization, with the input panel waiting for a submission. Stop the server with `Ctrl+C` when finished.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Activation blocked | Review the process-scoped execution-policy step and organization policy |
| `langgraph` not recognized | Activate the intended environment and install `langgraph-cli[inmem]` there |
| Missing API key | Check the module's `.env` path, variable spelling, and whether the file was saved as `.env.txt` |
| Studio cannot connect | Keep the local server running and use its printed Studio URL |
| Empty keys after the helper | The PowerShell process variables were missing; configure the module file locally |

## Credentials and publishing

Commit only `.env.example` files with placeholders. Never commit real `.env` files or API keys. Rotate any key exposed in a screenshot or commit. `.gitignore` does not remove secrets already committed. Keep credentials out of browser code.

The HTML article includes embedded images and can be uploaded as a single file to a static host such as Mochahost. Retain its filename if linking from the existing blog menu. Publishing these files does not deploy an agent or a server.

## References

- [Introduction to LangGraph — LangChain Academy](https://academy.langchain.com/courses/intro-to-langgraph)
- [Official course repository](https://github.com/langchain-ai/langchain-academy)
- [LangGraph overview](https://docs.langchain.com/oss/python/langgraph/overview)
- [Jupyter installation](https://jupyter.org/install)
- [LangSmith account and API key](https://docs.langchain.com/langsmith/create-account-api-key)
- [LangSmith Studio](https://docs.langchain.com/langsmith/studio)
- [Local development and testing](https://docs.langchain.com/langsmith/local-dev-testing)
- [OpenAI quickstart](https://developers.openai.com/api/docs/quickstart)
- [Tavily documentation](https://docs.tavily.com/)
- [Python virtual environments](https://docs.python.org/3/library/venv.html)
- [PowerShell execution policy](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy)
- [WinGet](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

Independent learning notes by Victor Pereira, November 7, 2026. Not an official LangChain course or distribution. Third-party software remains subject to its own licenses. The course code is linked, not redistributed here.
