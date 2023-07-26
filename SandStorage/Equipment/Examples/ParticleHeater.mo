within SandStorage.Equipment.Examples;
model ParticleHeater
"Example model to test the particle heater"
  extends Modelica.Icons.Example;
  package MediumSan = SandStorage.Media.SandPolynomial (
    T_default=600+273.15);
  parameter Modelica.Units.SI.MassFlowRate m_flow_nominal = 0.05;
  parameter Modelica.Units.SI.Temperature TIn_nominal = 600+273.15;
  parameter Modelica.Units.SI.Temperature TOut_nominal = 775+273.15;
  parameter Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cp_default=
    MediumSan.specificHeatCapacityCp(
      MediumSan.setState_pTX(
        T=((TOut_nominal-TIn_nominal)/2+TIn_nominal),
        p=MediumSan.p_default))
        "cp default value";
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_nominal=
    m_flow_nominal*cp_default*(TOut_nominal-TIn_nominal)
    "Nominal heat flow rate";
  Buildings.Fluid.Sources.MassFlowSource_T sanIn(
    redeclare package Medium = MediumSan,
    m_flow=m_flow_nominal,
    use_m_flow_in=false,
    nPorts=1)
    "Inlet"
    annotation (Placement(transformation(extent={{-60,0},{-40,20}})));
  SandStorage.BaseClasses.Boundary_pT_highP sanOut(
    redeclare package Medium = MediumSan,
    nPorts=1) "Outlet sand volume"
    annotation (Placement(transformation(extent={{60,0},{40,20}})));
  Buildings.Fluid.HeatExchangers.HeaterCooler_u hea(
    redeclare package Medium = MediumSan,
    m_flow_nominal=m_flow_nominal,
    show_T=true,
    dp_nominal=0,
    Q_flow_nominal=Q_flow_nominal)
    "Particle heater"
    annotation (Placement(transformation(extent={{-10,0},{10,20}})));
  Modelica.Blocks.Sources.Ramp uSet(
    height=1,
    duration=3600/3,
    startTime=3600/3) "Control signal"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
equation
  connect(sanIn.ports[1], hea.port_a)
    annotation (Line(points={{-40,10},{-10,10}}, color={0,127,255}));
  connect(hea.port_b, sanOut.ports[1])
    annotation (Line(points={{10,10},{40,10}}, color={0,127,255}));
  connect(uSet.y, hea.u) annotation (Line(points={{-39,50},{-18,50},{-18,16},{-12,
          16}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=3600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Equipment/Examples/ParticleHeater.mos"
        "Simulate and plot"),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end ParticleHeater;
