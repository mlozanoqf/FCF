$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$outputDirectory = Join-Path $projectRoot "docs"
$quartoConfigPath = Join-Path $projectRoot "_quarto.yml"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path $outputDirectory)) {
  throw "The rendered docs directory was not found."
}

if (-not (Test-Path $quartoConfigPath)) {
  throw "The Quarto configuration file was not found."
}

$quartoConfig = [System.IO.File]::ReadAllText($quartoConfigPath, $utf8NoBom)
$courseCodeMatch = [regex]::Match(
  $quartoConfig,
  '(?m)^\s{2}code:\s*(.+?)\s*$'
)

if (-not $courseCodeMatch.Success) {
  throw "The course code could not be read from _quarto.yml."
}

$courseCode = $courseCodeMatch.Groups[1].Value.Trim().Trim('"').Trim("'")

[System.IO.File]::WriteAllText(
  (Join-Path $outputDirectory ".nojekyll"),
  "",
  $utf8NoBom
)

$sidebarHomePattern = @'
<li class="sidebar-item">\s*<div class="sidebar-item-container">\s*<a href="\./index\.html" class="sidebar-item-text sidebar-link(?: active)?"><span class="chapter-title">index\.html</span></a>\s*</div>\s*</li>\s*
'@

$homeBreadcrumbPattern = @'
<nav class="quarto-page-breadcrumbs" aria-label="breadcrumb"><ol class="breadcrumb"><li class="breadcrumb-item"><a href="\./index\.html"><span class="chapter-title">index\.html</span></a></li></ol></nav>\s*
'@

$previousHomePattern = @'
<div class="nav-page nav-page-previous">\s*<a href="\./index\.html" class="pagination-link" aria-label="index\.html">\s*<i class="bi bi-arrow-left-short"></i>\s*<span class="nav-page-text"><span class="chapter-title">index\.html</span></span>\s*</a>\s*</div>
'@

$regexOptions = [System.Text.RegularExpressions.RegexOptions]::Singleline
$previousHomeReplacement = "<div class=`"nav-page nav-page-previous`">`n  </div>"
$titlePattern = '<title>(.*?)</title>'

Get-ChildItem -Path $outputDirectory -Filter "*.html" -File | ForEach-Object {
  $html = [System.IO.File]::ReadAllText($_.FullName, $utf8NoBom)
  $cleanedHtml = [regex]::Replace($html, $sidebarHomePattern, "", $regexOptions)
  $cleanedHtml = [regex]::Replace($cleanedHtml, $homeBreadcrumbPattern, "", $regexOptions)
  $cleanedHtml = [regex]::Replace(
    $cleanedHtml,
    $previousHomePattern,
    $previousHomeReplacement,
    $regexOptions
  )

  $titleMatch = [regex]::Match($cleanedHtml, $titlePattern, $regexOptions)
  if (-not $titleMatch.Success) {
    throw "The browser title could not be found in $($_.Name)."
  }

  if ($_.Name -eq "index.html") {
    $browserTitle = "$courseCode syllabus"
  } else {
    $pageTitle = [regex]::Replace(
      $titleMatch.Groups[1].Value,
      '\s+[\u2013\u2014-]\s+.*$',
      ""
    ).Trim()

    if ([string]::IsNullOrWhiteSpace($pageTitle)) {
      throw "The page title could not be determined for $($_.Name)."
    }

    $browserTitle = "$pageTitle $([char]0x2013) $courseCode"
  }

  $cleanedHtml = [regex]::Replace(
    $cleanedHtml,
    $titlePattern,
    "<title>$browserTitle</title>",
    $regexOptions
  )

  if ($cleanedHtml -ne $html) {
    [System.IO.File]::WriteAllText($_.FullName, $cleanedHtml, $utf8NoBom)
  }
}
