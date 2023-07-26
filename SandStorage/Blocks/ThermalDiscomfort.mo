within SandStorage.Blocks;
model ThermalDiscomfort
"KPI for thermal discomfort"
  extends Modelica.Blocks.Interfaces.SO(y(unit="K.s"));
  parameter Integer n(min=1)=1 "Number of thermal zones in the building";
  Modelica.Blocks.Interfaces.RealInput TZon[n](unit="K") "Zone temperature"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Continuous.Integrator dis(y(unit="K.s")) "Discomfort"
    annotation (Placement(transformation(extent={{70,-10},{90,10}})));

  Modelica.Blocks.Interfaces.RealInput THeaLow[n](unit="K")
    "Lower temperature bound of heating setpoint for each zone"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.RealInput TCooUpp[n](unit="K")
    "Upper temperature bound of cooling setpoint for each zone"
    annotation (Placement(transformation(extent={{-140,-80},{-100,-40}})));
  Modelica.Blocks.Math.Max maxHea[n] "Max of heating"
    annotation (Placement(transformation(extent={{-30,26},{-10,46}})));
  Modelica.Blocks.Math.Max maxCoo[n] "Max of cooling"
    annotation (Placement(transformation(extent={{-30,-58},{-10,-38}})));
  Modelica.Blocks.Sources.Constant zer[n](each k=0) "Zero"
    annotation (Placement(transformation(extent={{-70,70},{-50,90}})));
  Modelica.Blocks.Math.Add diffHea[n](each k1=-1) "Under heating"
    annotation (Placement(transformation(extent={{-70,20},{-50,40}})));
  Modelica.Blocks.Math.Add diffCoo[n](each k2=-1) "Cooling difference"
    annotation (Placement(transformation(extent={{-70,-64},{-50,-44}})));
  Modelica.Blocks.Math.MultiSum disRatHea(final k=fill(1, n), nu=n)
    "Discomfort rate (heating)"
    annotation (Placement(transformation(extent={{4,30},{16,42}})));
  Modelica.Blocks.Math.MultiSum disRatCoo(final k=fill(1, n), nu=n)
    "Discomfort rate (cooling)"
    annotation (Placement(transformation(extent={{4,-54},{16,-42}})));
  Modelica.Blocks.Math.Add add
    annotation (Placement(transformation(extent={{30,-10},{50,10}})));
equation
  connect(TZon, diffHea.u1) annotation (Line(points={{-120,60},{-90,60},{-90,36},
          {-72,36}}, color={0,0,127}));
  connect(THeaLow, diffHea.u2) annotation (Line(points={{-120,0},{-80,0},{-80,24},
          {-72,24}}, color={0,0,127}));
  connect(TZon, diffCoo.u1) annotation (Line(points={{-120,60},{-90,60},{-90,-48},
          {-72,-48}}, color={0,0,127}));
  connect(TCooUpp, diffCoo.u2) annotation (Line(points={{-120,-60},{-72,-60}},
                           color={0,0,127}));
  connect(diffCoo.y, maxCoo.u2)
    annotation (Line(points={{-49,-54},{-32,-54}}, color={0,0,127}));
  connect(diffHea.y, maxHea.u2)
    annotation (Line(points={{-49,30},{-32,30}}, color={0,0,127}));
  connect(zer.y, maxHea.u1) annotation (Line(points={{-49,80},{-40,80},{-40,42},
          {-32,42}}, color={0,0,127}));
  connect(zer.y, maxCoo.u1) annotation (Line(points={{-49,80},{-40,80},{-40,-42},
          {-32,-42}}, color={0,0,127}));
  connect(maxHea.y, disRatHea.u)
    annotation (Line(points={{-9,36},{4,36}}, color={0,0,127}));
  connect(maxCoo.y, disRatCoo.u)
    annotation (Line(points={{-9,-48},{4,-48}}, color={0,0,127}));
  connect(disRatHea.y, add.u1) annotation (Line(points={{17.02,36},{20,36},{20,6},
          {28,6}},                  color={0,0,127}));
  connect(disRatCoo.y, add.u2) annotation (Line(points={{17.02,-48},{20,-48},{20,
          -6},{28,-6}},                   color={0,0,127}));
  connect(add.y, dis.u)
    annotation (Line(points={{51,0},{68,0}}, color={0,0,127}));
  connect(dis.y, y) annotation (Line(points={{91,0},{110,0}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Calculates the thermal discomfort in Kelvin-hours.
</p>
</html>"));
end ThermalDiscomfort;
