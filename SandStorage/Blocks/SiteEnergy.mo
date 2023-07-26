within SandStorage.Blocks;
model SiteEnergy
  "KPI for site energy"
  extends Modelica.Blocks.Interfaces.SO(y(unit="J/m2"));
  parameter Integer n(final min=1)=1 "Number of sources";
  parameter Modelica.Units.SI.Area A(final min=0)
    "Total floor area of building";
  Modelica.Blocks.Interfaces.RealInput P[n](each unit="W")
    "Power (n number of sources)"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Continuous.Integrator E(y(unit="J")) "Energy"
    annotation (Placement(transformation(extent={{-20,-10},{0,10}})));
  Modelica.Blocks.Math.Gain to_J_A(k=1/A) "Normalize by floor area"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Modelica.Blocks.Math.MultiSum PTot(k=fill(1, n), nu=n) "Total power"
    annotation (Placement(transformation(extent={{-76,-6},{-64,6}})));
equation
  connect(P, PTot.u)
    annotation (Line(points={{-120,0},{-76,0}}, color={0,0,127}));
  connect(PTot.y, E.u)
    annotation (Line(points={{-62.98,0},{-22,0}}, color={0,0,127}));
  connect(E.y, to_J_A.u)
    annotation (Line(points={{1,0},{38,0}}, color={0,0,127}));
  connect(to_J_A.y, y)
    annotation (Line(points={{61,0},{110,0}}, color={0,0,127}));
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
end SiteEnergy;
