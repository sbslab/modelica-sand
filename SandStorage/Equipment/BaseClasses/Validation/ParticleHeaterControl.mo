within SandStorage.Equipment.BaseClasses.Validation;
model ParticleHeaterControl "Example model to demonstrate the particle heater control"
  extends Modelica.Icons.Example;
  SandStorage.Equipment.BaseClasses.ParticleHeaterControl con(
    TMaxSet=1273.15,
    TTan_nominal=1073.15,
    m_flow_nominal=20,
    cp=1000,
    P_nominal=20*1000*500)
    annotation (Placement(transformation(extent={{-10,0},{10,20}})));
  Modelica.Blocks.Sources.Ramp T(
    height=1000,
    duration(displayUnit="h") = 10800,
    offset=250 + 273.15,
    startTime(displayUnit="h") = 3600) "Temperature"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
  Modelica.Blocks.Sources.Sine PRen(
    amplitude=20*1000*500*0.75,
    f=1/3600,
    offset=20*1000*500*0.75)
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
equation
  connect(con.T, T.y) annotation (Line(points={{-12,16},{-32,16},{-32,50},{-39,
          50}}, color={0,0,127}));
  connect(PRen.y, con.PRen) annotation (Line(points={{-39,-30},{-20,-30},{-20,2},
          {-12,2}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=18000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Equipment/BaseClasses/Validation/ParticleHeaterControl.mos"
        "Simulate and plot"),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Validation model for the renewable-responsive particle heater control.
</p>
</html>"));
end ParticleHeaterControl;
