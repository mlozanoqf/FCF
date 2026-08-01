$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$outputDirectory = Join-Path $projectRoot "includes\generated"
$outputPath = Join-Path $outputDirectory "book-metadata.html"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$safeDirectory = $projectRoot.Replace("\", "/")

try {
  $editionHash = (& git -c "safe.directory=$safeDirectory" rev-parse HEAD 2>$null).Trim()
} catch {
  $editionHash = ""
}

if ($editionHash -notmatch "^[0-9a-f]{40,64}$") {
  throw "Could not determine the current Git commit SHA."
}

$editionShort = $editionHash.Substring(0, 7)
$culture = [System.Globalization.CultureInfo]::GetCultureInfo("en-US")
$timeZone = $null

foreach ($timeZoneId in @("America/Mexico_City", "Central Standard Time (Mexico)")) {
  try {
    $timeZone = [System.TimeZoneInfo]::FindSystemTimeZoneById($timeZoneId)
    break
  } catch {
    $timeZone = $null
  }
}

if ($timeZone) {
  $publishedTime = [System.TimeZoneInfo]::ConvertTime(
    [System.DateTimeOffset]::UtcNow,
    $timeZone
  )
} else {
  $publishedTime = Get-Date
}

$publishedLabel = $publishedTime.ToString("MMMM d, yyyy, h:mm:ss tt", $culture)
$publishedLabel = $publishedLabel.Replace(" AM", " am").Replace(" PM", " pm") + "."

$metadataHtml = @"
<script>
(function () {
  var editionPrefix = "Edition: ";
  var editionShort = "$editionShort";
  var editionHash = "$editionHash";
  var publishedLabel = "$publishedLabel";

  function applyBookMetadata() {
    var titleBlock = document.querySelector("#title-block-header .quarto-title");
    var subtitle = document.querySelector("#title-block-header .subtitle");
    var existingEdition = document.querySelector("#title-block-header .book-edition-line");

    if (titleBlock && !existingEdition) {
      var editionLine = document.createElement("p");
      editionLine.className = "book-edition-line";
      editionLine.appendChild(document.createTextNode(editionPrefix));

      var editionCode = document.createElement("code");
      editionCode.className = "book-edition-code";
      editionCode.textContent = editionShort;
      editionLine.appendChild(editionCode);
      editionLine.title = editionPrefix + editionShort;

      if (subtitle && subtitle.parentNode) {
        subtitle.insertAdjacentElement("afterend", editionLine);
      } else {
        titleBlock.appendChild(editionLine);
      }
    }

    document.documentElement.setAttribute("data-book-edition", editionHash);

    document.querySelectorAll("#title-block-header .quarto-title-meta-heading").forEach(function (heading) {
      var text = heading.textContent.trim();
      if (text !== "Date" && text !== "Published") {
        return;
      }

      heading.textContent = "Published";
      var item = heading.parentElement;
      var date = item ? item.querySelector(".quarto-title-meta-contents p") : null;
      if (date) {
        date.textContent = publishedLabel;
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", applyBookMetadata);
  } else {
    applyBookMetadata();
  }
})();
</script>
"@

New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
[System.IO.File]::WriteAllText($outputPath, $metadataHtml, $utf8NoBom)
