BeginPackage["JerryI`Terakitchen`Views`Summary`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Language`",
    "JerryI`Misc`Async`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`WLX`",
    "JerryI`WLX`Importer`",
    "JerryI`WLX`WebUI`",
    "CoffeeLiqueur`Extensions`EditorView`",
    "JerryI`Misc`WLJS`Transport`",
    "CoffeeLiqueur`Extensions`InputsOutputs`",
    "CoffeeLiqueur`Extensions`Communication`",
    "JerryI`TDSTools`Trace`",
    "JerryI`TDSTools`Transmission`",
    "JerryI`TDSTools`Material`",
    "CoffeeLiqueur`Extensions`Graphics`",
    "CoffeeLiqueur`Extensions`System`"
}]

Begin["`Private`"]

root = $InputFileName // DirectoryName;

modules = FileNameJoin[{root // ParentDirectory // ParentDirectory// ParentDirectory, "Modules"}];
projectRoot = modules // ParentDirectory;

Needs["JerryI`Terakitchen`Services`Fitting`Proto`" -> "fitting`", FileNameJoin[{modules, "Fitting", "Proto.wl"}] ];


{summary, views, exporter} = ImportComponent[FileNameJoin[{root, "Summary.wlx"}] ];

End[]

EndPackage[]

{JerryI`Terakitchen`Views`Summary`Private`summary, JerryI`Terakitchen`Views`Summary`Private`views, JerryI`Terakitchen`Views`Summary`Private`exporter}