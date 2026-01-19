BeginPackage["JerryI`Terakitchen`Services`Fitting`Proto`", {
    "CoffeeLiqueur`Misc`Events`",
    "CoffeeLiqueur`Misc`Language`",
    "CoffeeLiqueur`Misc`Async`",
    "CoffeeLiqueur`Misc`Events`Promise`",
    "CoffeeLiqueur`WLX`",
    "CoffeeLiqueur`WLX`Importer`",
    "CoffeeLiqueur`WLX`WebUI`",
    "CoffeeLiqueur`Extensions`EditorView`",
    "CoffeeLiqueur`Misc`WLJS`Transport`",
    "CoffeeLiqueur`Extensions`InputsOutputs`",
    "CoffeeLiqueur`Extensions`Communication`",
    "JerryI`TDSTools`Trace`",
    "JerryI`TDSTools`Transmission`",
    "JerryI`TDSTools`Material`",
    "CoffeeLiqueur`Extensions`Graphics`",
    "CoffeeLiqueur`Extensions`System`"
}]


widget;
generate;

Begin["`Private`"];

root = $InputFileName // DirectoryName;
common = FileNameJoin[{$InputFileName // DirectoryName // ParentDirectory // ParentDirectory // ParentDirectory, "Common"}];

{widget, silentGeneration} = ImportComponent[FileNameJoin[{root, "Widget.wlx"}] ];

getThickness[object_] := QuantityMagnitude[object["Thickness"], "Millimeters"]
getSpectrum[object_] := QuantityMagnitude[object["Tags"]["Traces"][[1]]["Spectrum"], {1/"Centimeters", 1}]
getReferenceSpectrum[object_] := QuantityMagnitude[object["Tags"]["Traces"][[2]]["Spectrum"], {1/"Centimeters", 1}]
getTrace[object_] := QuantityMagnitude[object["Tags"]["Traces"][[1]], {"Picoseconds", 1}]
getReferenceTrace[object_] := QuantityMagnitude[object["Tags"]["Traces"][[2]], {"Picoseconds", 1}]
getAbsorption[t_TransmissionObject] := Drop[QuantityMagnitude[t["Approximated \[Alpha]"], {1/"Centimeters", 1/"Centimeters"}], 10]
getAbsorption[t_MaterialParameters] := Drop[QuantityMagnitude[t["\[Alpha]"], {1/"Centimeters", 1/"Centimeters"}], 10]
 
resampleFromTo[td_TDTrace, ref_TDTrace] := With[{
  reference = QuantityMagnitude[ref["Trace"], {"Picoseconds", 1}],
  trace = Interpolation[QuantityMagnitude[td["Trace"], {"Picoseconds", 1}], InterpolationOrder->1, "ExtrapolationHandler" -> {(0.) &, "WarningMessage"->True}]
},
  TDTrace[QuantityArray[Map[Function[x, {x, trace[x]}], reference[[All,1]]], {"Picoseconds", 1}]]
]

calcFilter[bandpass_, spectrum_] := With[{
  a = bandpass[[1]], c0 = 2 bandpass[[2]], 
  c = Clip[2 bandpass[[2]]], 
  b = bandpass[[3]]
}, Map[Function[x, 
   ((1 - c) + c(1 + 50 (c0 - c)(c0 - c))  (*FB[*)(((*SpB[*)Power[E(*|*),(*|*)-(*FB[*)(((*SpB[*)Power[(x-a)(*|*),(*|*)2](*]SpB*))(*,*)/(*,*)(2 ((*SpB[*)Power[b(*|*),(*|*)2](*]SpB*))))(*]FB*)](*]SpB*))(*,*)/(*,*)(1))(*]FB*))
], spectrum[[All,1]]]]

applyFilter[src_, filter_] := {src[[All,1]], src[[All,2]] filter} // Transpose

calcTrace[spectrum_] := QuantityMagnitude[TDTrace[QuantityArray[spectrum, {1/"Centimeters", 1}]]["Trace"], {"Picoseconds", 1}]

calcPowerSpectrum[spectrum_] := Drop[Drop[spectrum, -Floor[Length[spectrum]/2]], 8] // Abs

getMinMax[spectrum_] := spectrum[[All,1]] // MinMax
getMaxY[spectrum_] := Max[Drop[spectrum[[All,2]], 8]]

t[ω_, L_, False, n_] := With[{
  c = 3.0 (*SpB[*)Power[10(*|*),(*|*)10](*]SpB*), cm2THz = 33.4,
  m = n[ω]
},
  (*FB[*)((4m)(*,*)/(*,*)((*SpB[*)Power[(m+1)(*|*),(*|*)2](*]SpB*)))(*]FB*) Exp[- (*FB[*)((I 2π (*SpB[*)Power[10(*|*),(*|*)12](*]SpB*) ω (m-1) L)(*,*)/(*,*)(c cm2THz 10.0))(*]FB*) ] 

]

t[ω_, L_, True, n_] := With[{
  c = 3.0 (*SpB[*)Power[10(*|*),(*|*)10](*]SpB*), cm2THz = 33.4,
  m = n[ω]
},
  (*FB[*)((4m)(*,*)/(*,*)((*SpB[*)Power[(m+1)(*|*),(*|*)2](*]SpB*)))(*]FB*) Exp[- (*FB[*)((I 2π (*SpB[*)Power[10(*|*),(*|*)12](*]SpB*) ω (m-1) L)(*,*)/(*,*)(c cm2THz 10.0))(*]FB*) ] (*FB[*)((1)(*,*)/(*,*)(1 - (*SpB[*)Power[((*FB[*)((m - 1)(*,*)/(*,*)(m + 1))(*]FB*))(*|*),(*|*)2](*]SpB*) Exp[-2 (*FB[*)((I 2π (*SpB[*)Power[10(*|*),(*|*)12](*]SpB*) ω m L)(*,*)/(*,*)(c cm2THz 10.0))(*]FB*) ]))(*]FB*)

]

calcModel[scale_, fp_, L_, \[Epsilon]_, parametersSet_] := With[{ 
  function =  scale t[
   #, L, fp, 
   Function[ω, (*SqB[*)Sqrt[\[Epsilon] + Total[Table[ (*FB[*)((p[[1]])(*,*)/(*,*)((*SpB[*)Power[p[[2]](*|*),(*|*)2](*]SpB*) - (*SpB[*)Power[ω(*|*),(*|*)2](*]SpB*) + I p[[3]] ω))(*]FB*) , {p, parametersSet}]]](*]SqB*)]
  ]
},
  function&
]

calcDielectric[scale_, fp_, L_, \[Epsilon]_, parametersSet_] := With[{ 

},
  Function[ω, (*SqB[*)Sqrt[\[Epsilon] + Total[Table[ (*FB[*)((p[[1]])(*,*)/(*,*)((*SpB[*)Power[p[[2]](*|*),(*|*)2](*]SpB*) - (*SpB[*)Power[ω(*|*),(*|*)2](*]SpB*) + I p[[3]] ω))(*]FB*) , {p, parametersSet}]]](*]SqB*)]
]

calcAbsorption[sourceSpectrum_, model_] := With[{ n = -Im[ model[#[[1]]]  ], w = #[[1]]}, 
    {w,  (n 4 \[Pi]  10^12 w)/(33.356 2.9979 10^10) }
] &/@ Drop[sourceSpectrum,10]


calcSpectrum[sourceSpectrum_, model_] := {#[[1]], #[[2]] Conjugate[model[#[[1]]]]} &/@ sourceSpectrum

cache[_, _] := False;
generate[t_, sessionId_] := cache[t//Hash, sessionId] /; (cache[t//Hash, sessionId] =!= False)
generate[t_, sessionId_] := With[{gen = silentGeneration[t]},
  cache[t//Hash, sessionId] = <|
    "Transmission" -> QuantityArray[gen[[2]], {1/"Centimeters", 1}],
    "\[Alpha]" -> QuantityArray[gen[[1]], {1/"Centimeters", 1/"Centimeters"}]
  |>
]

End[];
EndPackage[]