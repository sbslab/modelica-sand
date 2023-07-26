within SandStorage.Equipment.Examples;
model ParticleStorageWithHX
  "Example model to test the particle storage tank with heat exchanger"
  extends Modelica.Icons.Example;
  package MediumSan = SandStorage.Media.SandPolynomial (
    T_default=600+273.15);
  package MediumAir = Modelica.Media.Air.ReferenceAir.Air_pT;
  //Buildings.Media.Air;
  parameter Modelica.Units.SI.MassFlowRate mSan_flow_nominal = 19.81;
  parameter Modelica.Units.SI.MassFlowRate mAir_flow_nominal=14.63;
   // mSan_flow_nominal*cpSan_default/cpAir_default;
  parameter Modelica.Units.SI.Temperature TSanOut_nominal = 726.9+273.15;
  parameter Modelica.Units.SI.Temperature TSanIn_nominal = 1200+273.15;
  parameter Modelica.Units.SI.Temperature TAirOut_nominal = 1000+273.15;
  parameter Modelica.Units.SI.Temperature TAirIn_nominal = 238+273.15;
  parameter Modelica.Units.SI.AbsolutePressure pAirOut_nominal = 150000;
  parameter Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cpAir_default=
    MediumAir.specificHeatCapacityCp(
      MediumAir.setState_pTX(
        T=((TAirOut_nominal-TAirIn_nominal)/2+TAirIn_nominal),
        p=pAirOut_nominal))
        "cp default value for air";
  parameter Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cpSan_default=
    MediumSan.specificHeatCapacityCp(
      MediumSan.setState_pTX(
        T=((TAirOut_nominal-TAirIn_nominal)/2+TAirIn_nominal),
        p=MediumSan.p_default))
        "cp default value for sand";
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_nominal=
    mAir_flow_nominal*cpAir_default*(TAirOut_nominal-TAirIn_nominal)
    "Nominal heat flow rate";
  parameter Modelica.Units.SI.Volume VTan=30 "Tank volume";
  parameter Modelica.Units.SI.Length hTan=15
    "Height of tank (without insulation)";
  parameter Modelica.Units.SI.Length dIns=0.25 "Thickness of insulation";
  parameter Modelica.Units.SI.ThermalConductivity kIns=0.04
    "Specific heat conductivity of insulation";
  parameter Modelica.Units.SI.Height hHex_a=tan.hTan-1
    "Height of portHex_a of the heat exchanger, measured from tank bottom";
  parameter Modelica.Units.SI.Height hHex_b=1
    "Height of portHex_b of the heat exchanger, measured from tank bottom";

  SandStorage.BaseClasses.Boundary_pT_highP sanOut(
      redeclare package Medium = MediumSan,
      nPorts=1) "Outlet sand volume"
    annotation (Placement(transformation(extent={{90,0},{70,20}})));
  Buildings.Fluid.Storage.StratifiedEnhancedInternalHex tan(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    show_T=true,
    VTan=VTan,
    hTan=hTan,
    dIns=dIns,
    kIns=kIns,
    redeclare package MediumHex = MediumAir,
    hHex_a=hHex_a,
    hHex_b=hHex_b,
    Q_flow_nominal=Q_flow_nominal,
    TTan_nominal=TSanIn_nominal,
    THex_nominal=TAirIn_nominal,
    mHex_flow_nominal=mAir_flow_nominal)
    "Particle tank with heat exchanger"
    annotation (Placement(transformation(extent={{30,0},{50,20}})));
  Buildings.Fluid.Sources.MassFlowSource_T airIn(
    redeclare package Medium = MediumAir,
    use_m_flow_in=true,
    T=TAirIn_nominal,
    nPorts=1)
    "Inlet air volume"
    annotation (Placement(transformation(extent={{-50,-30},{-30,-10}})));
  SandStorage.BaseClasses.Boundary_pT_highP airOut(
    redeclare package Medium = MediumAir,
    p=pAirOut_nominal,
    nPorts=1)
    "Outlet air volue"
    annotation (Placement(transformation(extent={{-50,-60},{-30,-40}})));

  Buildings.Fluid.Sources.MassFlowSource_T sanIn(
    redeclare package Medium = MediumSan,
    use_m_flow_in=true,
    T=TSanIn_nominal,
    nPorts=1)
    "Inlet"
    annotation (Placement(transformation(extent={{-20,18},{0,38}})));
  Modelica.Blocks.Sources.Ramp ramAir(
    height=mAir_flow_nominal,
    duration(displayUnit="d") = 259200,
    offset=0,
    startTime(displayUnit="d") = 2592000)
    "Mass flow rate signal"
    annotation (Placement(transformation(extent={{-90,-22},{-70,-2}})));
  Modelica.Blocks.Sources.Ramp ramSan(
    height=mSan_flow_nominal,
    duration(displayUnit="d") = 259200,
    offset=0,
    startTime(displayUnit="d"))
    "Mass flow rate signal"
    annotation (Placement(transformation(extent={{-60,26},{-40,46}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTAirIn(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal)
    annotation (Placement(transformation(extent={{-20,-30},{0,-10}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTAirOut(
    redeclare package Medium = MediumAir,
    m_flow_nominal=mAir_flow_nominal)
    annotation (Placement(transformation(extent={{20,-60},{0,-40}})));
equation
  connect(tan.port_b, sanOut.ports[1]) annotation (Line(points={{50,10},{70,10}},
                            color={0,127,255}));
  connect(sanIn.ports[1], tan.port_a) annotation (Line(points={{0,28},{20,28},{20,
          10},{30,10}},       color={0,127,255}));
  connect(ramAir.y, airIn.m_flow_in)
    annotation (Line(points={{-69,-12},{-52,-12}}, color={0,0,127}));
  connect(ramSan.y, sanIn.m_flow_in)
    annotation (Line(points={{-39,36},{-22,36}}, color={0,0,127}));
  connect(airIn.ports[1], senTAirIn.port_a)
    annotation (Line(points={{-30,-20},{-20,-20}}, color={0,127,255}));
  connect(senTAirIn.port_b, tan.portHex_a) annotation (Line(points={{0,-20},{10,
          -20},{10,6.2},{30,6.2}}, color={0,127,255}));
  connect(tan.portHex_b, senTAirOut.port_a) annotation (Line(points={{30,2},{26,
          2},{26,-50},{20,-50}}, color={0,127,255}));
  connect(senTAirOut.port_b, airOut.ports[1])
    annotation (Line(points={{0,-50},{-30,-50}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=5184000,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Equipment/Examples/ParticleStorageWithHX.mos"
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
Example model for particle sand storage tank with an internal heat exchanger.
</p>
</html>"));
end ParticleStorageWithHX;
