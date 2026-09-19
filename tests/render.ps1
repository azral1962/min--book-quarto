$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$output = Join-Path $PSScriptRoot 'output'
New-Item -ItemType Directory -Force (Join-Path $output '_extensions') | Out-Null
Copy-Item -LiteralPath (Join-Path $repo '_extensions/min-book-quarto') -Destination (Join-Path $output '_extensions') -Recurse -Force
foreach ($fixture in @('variants', 'elegance')) {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot "$fixture.qmd") -Destination $output -Force
    & quarto render (Join-Path $output "$fixture.qmd")
    if ($LASTEXITCODE -ne 0) { throw "Render failed: $fixture" }
    if (!(Test-Path (Join-Path $output "$fixture.pdf"))) { throw "Missing PDF: $fixture" }
}
& quarto render (Join-Path $repo 'template.qmd')
if ($LASTEXITCODE -ne 0) { throw 'Starter render failed' }
$book = Join-Path $repo 'examples/book'
New-Item -ItemType Directory -Force (Join-Path $book '_extensions') | Out-Null
Copy-Item -LiteralPath (Join-Path $repo '_extensions/min-book-quarto') -Destination (Join-Path $book '_extensions') -Recurse -Force
& quarto render $book
if ($LASTEXITCODE -ne 0) { throw 'Book render failed' }
Write-Host 'All four PDF render checks passed.'
