within SandStorage.Blocks.Validation;
model CarbonEmissions
  "Example model to validate the carbon emission calculations"
  extends Modelica.Icons.Example;

  parameter Modelica.Units.SI.Area A=1
    "Total floor area of building";
  Modelica.Blocks.Sources.Constant P(k=1000) "Power [Ws]"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
  SandStorage.Blocks.CarbonEmissions co2e_AZ(
    A=A,
    filNam="modelica://SandStorage/Resources/Data/CarbonEmissions/2B_Phoenix_AZ.mos")
    "Arizona carbon emissions"
    annotation (Placement(transformation(extent={{0,40},{20,60}})));
  SandStorage.Blocks.CarbonEmissions co2e_VT(
    A=A,
    filNam="modelica://SandStorage/Resources/Data/CarbonEmissions/6A_Burlington_VT.mos")
    "Vermont carbon emissions"
    annotation (Placement(transformation(extent={{0,-60},{20,-40}})));
  SandStorage.Blocks.CarbonEmissions co2e_CA(
    A=A,
    filNam="modelica://SandStorage/Resources/Data/CarbonEmissions/3C_SanFrancisco_CA.mos")
    "California carbon emissions"
    annotation (Placement(transformation(extent={{0,-10},{20,10}})));
equation
  connect(P.y, co2e_AZ.PEle)
    annotation (Line(points={{-39,50},{-2,50}}, color={0,0,127}));
  connect(P.y, co2e_CA.PEle) annotation (Line(points={{-39,50},{-8,50},{-8,0},{-2,
          0}}, color={0,0,127}));
  connect(P.y, co2e_VT.PEle) annotation (Line(points={{-39,50},{-8,50},{-8,-50},
          {-2,-50}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=604800,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),
      __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Blocks/Validation/CarbonEmissions.mos"
        "Simulate and plot"),
    Documentation(revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end CarbonEmissions;
