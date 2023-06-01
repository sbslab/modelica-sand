within SandStorage.Equipment.Examples;
model ParticleConveyor
"Example model to test the sand conveyor"
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

  Modelica.Blocks.Sources.Ramp mFlo(
    height=m_flow_nominal,
    duration=120,
    startTime=120)    "Mass flow rate"
    annotation (Placement(transformation(extent={{-80,-58},{-60,-38}})));
  SandStorage.Equipment.ParticleConveyor con(
    redeclare package Medium = MediumSan,
    m_flow_nominal=m_flow_nominal/2,
    h=20,
    use_inputFilter=false) "Particle conveyor"
    annotation (Placement(transformation(extent={{-10,0},{10,20}})));
  SandStorage.BaseClasses.Boundary_pT_highP pRef(
    redeclare package Medium = MediumSan,
    T=TIn_nominal,
    nPorts=1) "Reference pressure"
    annotation (Placement(transformation(extent={{-70,0},{-50,20}})));
  Buildings.Fluid.HeatExchangers.HeaterCooler_u hea(
    redeclare package Medium = MediumSan,
    m_flow_nominal=m_flow_nominal,
    show_T=true,
    dp_nominal=0,
    Q_flow_nominal=Q_flow_nominal)
    "Particle heater"
    annotation (Placement(transformation(extent={{10,40},{-10,60}})));
  Modelica.Blocks.Sources.Ramp uSet(
    height=0,
    duration=120,
    startTime=120)    "Control signal"
    annotation (Placement(transformation(extent={{60,46},{40,66}})));
  SandStorage.Equipment.ParticleConveyor conFil(
    redeclare package Medium = MediumSan,
    m_flow_nominal=m_flow_nominal/2,
    h=20,
    use_inputFilter=true,
    riseTime=120) "Particle conveyor with filter"
    annotation (Placement(transformation(extent={{-8,-30},{12,-10}})));
equation
  connect(mFlo.y, con.m_flow_in) annotation (Line(points={{-59,-48},{-20,-48},{
          -20,5},{-12,5}},
                       color={0,0,127}));
  connect(pRef.ports[1], con.port_a)
    annotation (Line(points={{-50,10},{-10,10}}, color={0,127,255}));
  connect(con.port_b, hea.port_a) annotation (Line(points={{10,10},{30,10},{30,50},
          {10,50}}, color={0,127,255}));
  connect(hea.port_b, con.port_a) annotation (Line(points={{-10,50},{-30,50},{-30,
          10},{-10,10}}, color={0,127,255}));
  connect(uSet.y, hea.u)
    annotation (Line(points={{39,56},{12,56}}, color={0,0,127}));
  connect(hea.port_a, conFil.port_b) annotation (Line(points={{10,50},{30,50},{
          30,-20},{12,-20}}, color={0,127,255}));
  connect(conFil.port_a, hea.port_b) annotation (Line(points={{-8,-20},{-30,-20},
          {-30,50},{-10,50}}, color={0,127,255}));
  connect(mFlo.y, conFil.m_flow_in) annotation (Line(points={{-59,-48},{-20,-48},
          {-20,-25},{-10,-25}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=3600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Equipment/Examples/ParticleConveyor.mos"
        "Simulate and plot"));
end ParticleConveyor;
