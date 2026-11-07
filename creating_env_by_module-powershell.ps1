for ($i = 1; $i -le 5; $i++) {
    Copy-Item "module-$i\studio\.env.example" "module-$i\studio\.env" -Force
    Add-Content -Path "module-$i\studio\.env" -Value "OPENAI_API_KEY=""$env:OPENAI_API_KEY"""
}
Add-Content -Path "module-4\studio\.env" -Value "TAVILY_API_KEY=""$env:TAVILY_API_KEY"""