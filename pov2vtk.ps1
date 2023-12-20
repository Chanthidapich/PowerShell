#setting up parameters, input and output file
param(
    [Parameter(Mandatory = $true)]
    [string]$inputFile,

    [Parameter(Mandatory = $true)]
    [string]$outputFile
)

# Read the input file 
$meshData = Get-Content $inputFile -Raw

# Extract the data starting from mesh 
$meshData = $meshData -replace "(?s).*?(mesh\s*{)", '$1'

#if there is no traingle, throw an error message 
if ($triangles.Count -eq 0) {
        throw "No triangles found in the input file."
    }

# Remove whitespace, empty lines, and comments from the mesh data
$meshData = $meshData -replace "(?m)^\s+|\s+$" -replace "(?m)^\s*?//.*" -replace "(?m)^\s*$"

# Split the data based on each traingles
$triangles = $meshData -split "(?m)triangle\s*{"

# try to remove the first element 
$triangles = $triangles[1..($triangles.Length - 1)]

# Create the VTK content
$vtkContent = "# vtk DataFile Version 4.0`n"
$vtkContent += "Unstructured Grid`n"
$vtkContent += "ASCII`n"
$vtkContent += "DATASET UNSTRUCTURED_GRID`n"
$vtkContent += "POINTS 0 float`n"
$vtkContent += "CELLS $($triangles.Length) $([int]($triangles.Length * 4))`n"

foreach ($triangle in $triangles) {
    # Extract each point from the triangle data
    $matches = [Regex]::Matches($triangle, "<([^>]*)>\s*([^<]*)\s*<([^>]*)>\s*([^<]*)\s*<([^>]*)>\s*([^<]*)")
    if ($matches.Success) {
        $point1 = $matches.Groups[1].Value
        $point2 = $matches.Groups[3].Value
        $point3 = $matches.Groups[5].Value

        # match the data to vtk content format
        $vtkContent += "3 $point1 $point2 $point3`n"
    }
}

# match CELL_TYPES to VTK content format
$vtkContent += "CELL_TYPES $($triangles.Length)`n"
for ($i = 0; $i -lt $triangles.Length; $i++) {
    $vtkContent += "5`n"
}

# Save the VTK content 
$vtkContent | Out-File $outputFile

Write-Host "Conversion completed."