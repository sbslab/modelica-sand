within SandStorage.Equipment.BaseClasses;
model ParticleHeaterControl
"Control block for the particle heater"
  extends Modelica.Blocks.Interfaces.SO;

  parameter Modelica.Units.SI.Temperature TMaxSet(min=0)
    "Maximum temperature setpoint";
  parameter Modelica.Units.SI.Temperature TTan_nominal(min=0)
    "Nominal tank temperature";
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal(min=0)
    "Nominal mass flow rate";
 parameter Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cp(min=0)
    "Specific heat";
  parameter Modelica.Units.SI.HeatFlowRate P_nominal(min=0)
    "Nominal power";
  Modelica.Blocks.Interfaces.RealInput T(
    final unit="K",
    final quantity="ThermodynamicTemperature",
    displayUnit="degC") "Temperature reading from tank"
    annotation (Placement(transformation(extent={{-140,40},{-100,80}})));
  Modelica.Blocks.Math.Gain PMaxLim(k=m_flow_nominal*cp)
    "Maximum power at the high operating limit"
    annotation (Placement(transformation(extent={{-8,56},{12,76}})));
  Modelica.Blocks.Math.Add dtMax(k2=-1)
    annotation (Placement(transformation(extent={{-40,56},{-20,76}})));
  Modelica.Blocks.Sources.Constant MaxTemSet(k=TMaxSet)
    "Max temperature setpoint"
    annotation (Placement(transformation(extent={{-80,70},{-60,90}})));
  Modelica.Blocks.Interfaces.RealInput PRen(
    final unit="W",
    final quantity="Power",
    displayUnit="W") "Power from renewable energy on site"
    annotation (Placement(transformation(extent={{-140,-100},{-100,-60}})));
  Modelica.Blocks.Math.Max max
    annotation (Placement(transformation(extent={{0,-61},{20,-39}})));
  Modelica.Blocks.Math.Min PSet "Minimum block (set power)"
    annotation (Placement(transformation(extent={{40,-10},{60,10}})));
  Modelica.Blocks.Math.Gain plrRen(k=1/P_nominal)
    "Normalized power (part load ratio)"
    annotation (Placement(transformation(extent={{-60,-90},{-40,-70}})));
  Modelica.Blocks.Sources.Constant zer(k=0) "Zero"
    annotation (Placement(transformation(extent={{-40,30},{-20,50}})));
  Modelica.Blocks.Math.Max max1
    annotation (Placement(transformation(extent={{32,49},{52,71}})));
  Buildings.Controls.OBC.CDL.Continuous.PID con(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    k=1,
    Ti(displayUnit="s") = 120) "Control"
    annotation (Placement(transformation(extent={{-40,-10},{-20,-30}})));
  Modelica.Blocks.Sources.Constant uni(k=1) "Unitary"
    annotation (Placement(transformation(extent={{-80,-30},{-60,-10}})));
  Modelica.Blocks.Math.Gain TRel(k=1/TTan_nominal) "Relative temperature"
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  Modelica.Blocks.Math.Gain plrMax(k=1/P_nominal)
    "Normalized power to hit max temp (part load ratio)"
    annotation (Placement(transformation(extent={{60,50},{80,70}})));
equation
  connect(MaxTemSet.y, dtMax.u1) annotation (Line(points={{-59,80},{-50,80},{-50,
          72},{-42,72}}, color={0,0,127}));
  connect(T, dtMax.u2)
    annotation (Line(points={{-120,60},{-42,60}}, color={0,0,127}));
  connect(dtMax.y, PMaxLim.u)
    annotation (Line(points={{-19,66},{-10,66}},color={0,0,127}));
  connect(max.y, PSet.u2) annotation (Line(points={{21,-50},{30,-50},{30,-6},{38,
          -6}},    color={0,0,127}));
  connect(PMaxLim.y, max1.u1)
    annotation (Line(points={{13,66},{30,66},{30,66.6}}, color={0,0,127}));
  connect(zer.y, max1.u2) annotation (Line(points={{-19,40},{22,40},{22,53.4},{30,
          53.4}},    color={0,0,127}));
  connect(max1.y, plrMax.u)
    annotation (Line(points={{53,60},{58,60}}, color={0,0,127}));
  connect(T, TRel.u) annotation (Line(points={{-120,60},{-90,60},{-90,10},{-82,10}},
        color={0,0,127}));
  connect(TRel.y, con.u_m)
    annotation (Line(points={{-59,10},{-30,10},{-30,-8}}, color={0,0,127}));
  connect(uni.y, con.u_s)
    annotation (Line(points={{-59,-20},{-42,-20}}, color={0,0,127}));
  connect(PRen, plrRen.u)
    annotation (Line(points={{-120,-80},{-62,-80}}, color={0,0,127}));
  connect(plrRen.y, max.u2) annotation (Line(points={{-39,-80},{-10,-80},{-10,-56.6},
          {-2,-56.6}}, color={0,0,127}));
  connect(con.y, max.u1) annotation (Line(points={{-18,-20},{-10,-20},{-10,-43.4},
          {-2,-43.4}}, color={0,0,127}));
  connect(plrMax.y, PSet.u1) annotation (Line(points={{81,60},{90,60},{90,20},{30,
          20},{30,6},{38,6}}, color={0,0,127}));
  connect(PSet.y, y)
    annotation (Line(points={{61,0},{110,0}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<p>Control is designed for a constant mass flow rate at the nominal condition.</p>
</html>", revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end ParticleHeaterControl;
