within SandStorage.Subsystems;
model SandLoop
"Example model to test the sand loop"
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
  parameter Modelica.Units.SI.HeatFlowRate QAir_flow_nominal=
    mAir_flow_nominal*cpAir_default*(TAirOut_nominal-TAirIn_nominal)
    "Nominal heat flow rate";
  parameter Modelica.Units.SI.HeatFlowRate QSan_flow_nominal=
    mSan_flow_nominal*cpSan_default*(TSanIn_nominal-TSanOut_nominal)
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
    Q_flow_nominal=QAir_flow_nominal,
    TTan_nominal=TSanIn_nominal,
    THex_nominal=TAirIn_nominal,
    mHex_flow_nominal=mAir_flow_nominal)
    "Particle tank with heat exchanger"
    annotation (Placement(transformation(extent={{42,0},{62,20}})));
  Buildings.Fluid.Sources.MassFlowSource_T airIn(
    redeclare package Medium = MediumAir,
    use_m_flow_in=true,
    T=TAirIn_nominal,
    nPorts=1)
    "Inlet air volume"
    annotation (Placement(transformation(extent={{-50,-60},{-30,-40}})));
  SandStorage.BaseClasses.Boundary_pT_highP airOut(
    redeclare package Medium = MediumAir,
    p=pAirOut_nominal,
    nPorts=1)
    "Outlet air volue"
    annotation (Placement(transformation(extent={{-50,-90},{-30,-70}})));

  Modelica.Blocks.Sources.Ramp ramAir(
    height=mAir_flow_nominal,
    duration(displayUnit="h") = 3600,
    offset=0,
    startTime(displayUnit="h") = 3600)   "Mass flow rate signal"
    annotation (Placement(transformation(extent={{-90,-52},{-70,-32}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTAirIn(redeclare package Medium =
        MediumAir, m_flow_nominal=mAir_flow_nominal)
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTAirOut(redeclare package
      Medium = MediumAir, m_flow_nominal=mAir_flow_nominal)
    annotation (Placement(transformation(extent={{20,-90},{0,-70}})));
  SandStorage.Equipment.ParticleConveyor mov(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    h=20) "Mover" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-10,20})));
  Buildings.Fluid.HeatExchangers.HeaterCooler_u hea(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    show_T=true,
    dp_nominal=0,
    Q_flow_nominal=QSan_flow_nominal)
    "Particle heater"
    annotation (Placement(transformation(extent={{0,40},{20,60}})));
  Modelica.Blocks.Sources.Ramp yHea(
    height=1,
    duration(displayUnit="h") = 21600,
    offset=0,
    startTime(displayUnit="h") = 3600)
                      "Control signal of the heater"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Modelica.Blocks.Logical.Hysteresis staMov(uLow=1e-4, uHigh=1e-2)
    "Mover state"
    annotation (Placement(transformation(extent={{-78,-10},{-58,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(realTrue=
        mSan_flow_nominal)
    annotation (Placement(transformation(extent={{-52,-10},{-32,10}})));
  SandStorage.BaseClasses.Boundary_pT_highP pRefSan(redeclare package Medium = MediumSan,
      nPorts=1) "Reference pressure sand"
    annotation (Placement(transformation(extent={{10,-10},{0,0}})));
equation
  connect(ramAir.y, airIn.m_flow_in)
    annotation (Line(points={{-69,-42},{-52,-42}}, color={0,0,127}));
  connect(airIn.ports[1], senTAirIn.port_a)
    annotation (Line(points={{-30,-50},{-20,-50}}, color={0,127,255}));
  connect(senTAirIn.port_b, tan.portHex_a) annotation (Line(points={{0,-50},{30,
          -50},{30,6.2},{42,6.2}}, color={0,127,255}));
  connect(tan.portHex_b, senTAirOut.port_a) annotation (Line(points={{42,2},{34,
          2},{34,-80},{20,-80}}, color={0,127,255}));
  connect(senTAirOut.port_b, airOut.ports[1])
    annotation (Line(points={{0,-80},{-30,-80}}, color={0,127,255}));
  connect(staMov.y, booToRea.u)
    annotation (Line(points={{-57,0},{-54,0}}, color={255,0,255}));
  connect(yHea.y, hea.u) annotation (Line(points={{-59,70},{-50,70},{-50,56},{-2,
          56}}, color={0,0,127}));
  connect(yHea.y, staMov.u) annotation (Line(points={{-59,70},{-50,70},{-50,40},
          {-90,40},{-90,0},{-80,0}}, color={0,0,127}));
  connect(booToRea.y, mov.m_flow_in)
    annotation (Line(points={{-30,0},{-5,0},{-5,8}}, color={0,0,127}));
  connect(mov.port_b, hea.port_a)
    annotation (Line(points={{-10,30},{-10,50},{0,50}}, color={0,127,255}));
  connect(hea.port_b, tan.port_a) annotation (Line(points={{20,50},{30,50},{30,10},
          {42,10}}, color={0,127,255}));
  connect(tan.port_b, mov.port_a) annotation (Line(points={{62,10},{70,10},{70,-20},
          {-10,-20},{-10,10}}, color={0,127,255}));
  connect(pRefSan.ports[1], mov.port_a)
    annotation (Line(points={{0,-5},{-10,-5},{-10,10}}, color={0,127,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=86400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Subsystems/SandLoop.mos"
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
Example model to test the implementation of the sand loop for the heating plant.
</p>
</html>"));
end SandLoop;
