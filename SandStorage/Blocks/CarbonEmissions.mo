within SandStorage.Blocks;
model CarbonEmissions
  "KPI for carbon emissions"
  extends Modelica.Blocks.Interfaces.SO(y(unit="kg/m2"));
//  parameter ENA.Blocks.KeyPerformanceIndicators.Types.States state=
//    ENA.Blocks.KeyPerformanceIndicators.Types.States.AZ
//    "US state";
  parameter Modelica.Units.SI.Area A(final min=0)
    "Total floor area of building";
  parameter String filNam="modelica://ENA/Resources/Data/CarbonEmissions/2B_Phoenix_AZ.mos"
    "File name with carbon emissions as time series";
// The below code does not simulate with Modelica.
// Format seems to be incompatible with the language construct.
/*  final parameter String filNam=
    if state==ENA.Blocks.KeyPerformanceIndicators.Types.States.AZ then 
      "modelica://ENA/Resources/Data/CarbonEmissions/2B_Phoenix_AZ.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.CA then 
      "modelica://ENA/Resources/Data/CarbonEmissions/3C_SanFrancisco_CA.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.CO then 
      "modelica://ENA/Resources/Data/CarbonEmissions/5B_Denver_CO.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.FL then 
      "modelica://ENA/Resources/Data/CarbonEmissions/1A_Miami_FL.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.GA then 
      "modelica://ENA/Resources/Data/CarbonEmissions/3A_Atlanta_GA.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.IL then 
      "modelica://ENA/Resources/Data/CarbonEmissions/5A_Chicago_IL.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.MD then 
      "modelica://ENA/Resources/Data/CarbonEmissions/4A_Baltimore_MD.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.MN then 
      "modelica://ENA/Resources/Data/CarbonEmissions/7_Duluth_MN.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.MT then 
      "modelica://ENA/Resources/Data/CarbonEmissions/6B_Helena_MT.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.NM then 
      "modelica://ENA/Resources/Data/CarbonEmissions/4B_Albuquerque_NM.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.TX then 
      "modelica://ENA/Resources/Data/CarbonEmissions/2A_Houston_TX.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.VT then 
      "modelica://ENA/Resources/Data/CarbonEmissions/6A_Burlington_VT.mos"
    elseif state==ENA.Blocks.KeyPerformanceIndicators.Types.States.WA then 
      "modelica://ENA/Resources/Data/CarbonEmissions/4C_Seattle_WA.mos"
    else 
      ""
    "File name with carbon emissions as time series, state"
    annotation(fixed=true);
*/
  Modelica.Blocks.Interfaces.RealInput PEle(unit="W")
    "Rate of electricity power consumption"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Sources.CombiTimeTable tab_co2e(
    tableOnFile=true,
    tableName="tab1",
    fileName=Modelica.Utilities.Files.loadResource(filNam),
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    columns={2},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "Reader for carbon emission rate (hourly)"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Modelica.Blocks.Math.Gain to_Ws(k=1/(3600*1e6))
    "Convert units from kg/MWh to kg/Ws"
    annotation (Placement(transformation(extent={{-40,60},{-20,80}})));
  Modelica.Blocks.Math.Product co2e_dot(y(unit="kg/s")) "Rate change in co2e emissions [kg/s]"
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
  Modelica.Blocks.Continuous.Integrator co2e(y(unit="kg"))
    "Carbon dioxide equivalent emissions"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));

  Modelica.Blocks.Math.Gain to_kg_A(k=1/A) "Normalize by floor area"
    annotation (Placement(transformation(extent={{72,-10},{92,10}})));
equation
  connect(PEle, co2e_dot.u2) annotation (Line(points={{-120,0},{-80,0},{-80,-6},
          {-2,-6}}, color={0,0,127}));
  connect(to_Ws.y, co2e_dot.u1) annotation (Line(points={{-19,70},{-10,70},{-10,
          6},{-2,6}}, color={0,0,127}));
  connect(co2e_dot.y, co2e.u)
    annotation (Line(points={{21,0},{38,0}}, color={0,0,127}));
  connect(tab_co2e.y[1], to_Ws.u)
    annotation (Line(points={{-59,70},{-42,70}}, color={0,0,127}));
  connect(co2e.y, to_kg_A.u)
    annotation (Line(points={{61,0},{70,0}}, color={0,0,127}));
  connect(to_kg_A.y, y)
    annotation (Line(points={{93,0},{110,0}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end CarbonEmissions;
