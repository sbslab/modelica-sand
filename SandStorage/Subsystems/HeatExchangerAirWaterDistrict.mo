within SandStorage.Subsystems;
model HeatExchangerAirWaterDistrict
  "Subsystem testing model for the air-to-water heat exchanger with controls and the district data"
  extends Modelica.Icons.Example;
    // Medium declarations
  package MediumWat = Modelica.Media.Water.StandardWater (
          p_default=963197,
          T_default=170+273.15);
  package MediumAir = Buildings.Media.Air;
      // Modelica.Media.Air.ReferenceAir.Air_pT

  parameter Modelica.Units.SI.MassFlowRate mWat_flow_nominal = 1.7;
  parameter Modelica.Units.SI.MassFlowRate mAir_flow_nominal=14.63;
  parameter Modelica.Units.SI.Temperature TAirOut_nominal = 238+273.15;
  parameter Modelica.Units.SI.Temperature TAirIn_nominal = 1000+273.15;
  parameter Modelica.Units.SI.Temperature TWatIn_nominal = 170+273.15;
    parameter Modelica.Units.SI.Temperature TWatOut_nominal =  180+273.15;
  parameter Modelica.Units.SI.AbsolutePressure pAirOut_nominal = 150000;
  parameter Modelica.Units.SI.AbsolutePressure pSte_nominal = 963197;
  parameter Modelica.Units.SI.PressureDifference dp_nominal = 6000;
  parameter Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cpAir_default=
    MediumAir.specificHeatCapacityCp(
      MediumAir.setState_pTX(
        T=((TAirOut_nominal-TAirIn_nominal)/2+TAirIn_nominal),
        p=pAirOut_nominal))
        "cp default value for air";
  parameter Modelica.Units.SI.HeatFlowRate QAir_flow_nominal=
    mAir_flow_nominal*cpAir_default*(TAirOut_nominal-TAirIn_nominal)
    "Nominal heat flow rate";

  parameter String filNam=
    "modelica://ENA/Resources/data/Examples/SandStorage/Systems/district2018.mos"
    "File name with thermal loads as time series";
  // Block instances
  Buildings.Fluid.Sources.MassFlowSource_T airIn(
    redeclare package Medium = MediumAir,
    use_T_in=true,
    use_m_flow_in=true,
    nPorts=1) "Inlet air volume"
    annotation (Placement(transformation(extent={{-30,20},{-10,40}})));
  Buildings.Fluid.Sources.MassFlowSource_T watIn(
    redeclare package Medium = MediumWat,
    m_flow=mWat_flow_nominal,
    T=TWatIn_nominal,
    use_m_flow_in=true,
    use_T_in=false,
    nPorts=1) "Inlet water volume"
    annotation (Placement(transformation(extent={{60,-40},{40,-20}})));
  Buildings.Fluid.Sources.Boundary_pT watOut(
    redeclare package Medium = MediumWat,
    p=pSte_nominal,
    nPorts=1) "Outlet water volume" annotation (Placement(transformation(extent={{100,20},
            {80,40}},           rotation=0.0)));
  SandStorage.BaseClasses.Boundary_pT_highP airOut(
    redeclare package Medium = MediumAir,
    p=pAirOut_nominal,
    T=TAirOut_nominal,
    nPorts=1) "Outlet air volue"
    annotation (Placement(transformation(extent={{-30,-40},{-10,-20}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senT(
    redeclare package Medium = MediumWat,
    m_flow_nominal=mWat_flow_nominal) "T sensor"
    annotation (Placement(transformation(extent={{40,20},{60,40}})));
  SandStorage.Equipment.HeatExchanger hex(
    m1_flow_nominal=mWat_flow_nominal,
    m2_flow_nominal=mAir_flow_nominal,
    show_T=true,
    dp1_nominal=dp_nominal,
    dp2_nominal=dp_nominal,
    redeclare package MediumWat = MediumWat,
    redeclare package MediumAir = MediumAir) "Heat exchanger" annotation (
      Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=-90,
        origin={10,10})));
  Buildings.Controls.OBC.CDL.Continuous.PID conFan(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    k=0.1,
    Ti=120)
    "Fan control"
    annotation (Placement(transformation(extent={{58,60},{38,80}})));
  Modelica.Blocks.Sources.Constant TSet(k=TWatOut_nominal)
    "Setpoint temperature for discharge steam"
    annotation (Placement(transformation(extent={{100,60},{80,80}})));
  Modelica.Blocks.Math.Gain mFloSet(k=mAir_flow_nominal)
    "Mass flow setpoint for air"
    annotation (Placement(transformation(extent={{0,60},{-20,80}})));
  Modelica.Blocks.Sources.Sine airNoi(
    amplitude=190,
    f=1/34560,
    offset=110,
    startTime=0)    "Air temperature noise"
    annotation (Placement(transformation(extent={{-100,60},{-80,80}})));
  Modelica.Blocks.Sources.Ramp ramAir(
    height=0,
    duration=3600/3,
    offset=TAirIn_nominal,
    startTime=3600/3) "Mass flow rate signal"
    annotation (Placement(transformation(extent={{-100,20},{-80,40}})));
  Modelica.Blocks.Math.Add TAir "Air temperature"
    annotation (Placement(transformation(extent={{-66,20},{-46,40}})));
  Modelica.Blocks.Sources.CombiTimeTable disDat(
    tableOnFile=true,
    tableName="tab1",
    fileName=Modelica.Utilities.Files.loadResource(filNam),
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    y(unit={"kg/s","K"}),
    offset={0,0},
    columns={2,3},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "Data reader for steam loads at district level (y[1] is mass flow rate, y[2] is steam supply temperature)"
    annotation (Placement(transformation(extent={{40,-70},{60,-50}})));
  Modelica.Blocks.Math.UnitConversions.To_degC TSteMea
    "Measured steam temperature"
    annotation (Placement(transformation(extent={{72,-90},{92,-70}})));
equation
  connect(airIn.ports[1], hex.port_a2)
    annotation (Line(points={{-10,30},{4,30},{4,20}},     color={0,127,255}));
  connect(hex.port_b2, airOut.ports[1]) annotation (Line(points={{4,3.55271e-15},
          {4,-30},{-10,-30}},   color={0,127,255}));
  connect(hex.port_b1, senT.port_a)
    annotation (Line(points={{16,20},{16,30},{40,30}}, color={0,127,255}));
  connect(senT.port_b, watOut.ports[1])
    annotation (Line(points={{60,30},{80,30}}, color={0,127,255}));
  connect(watIn.ports[1], hex.port_a1)
    annotation (Line(points={{40,-30},{16,-30},{16,0}}, color={0,127,255}));
  connect(senT.T, conFan.u_m)
    annotation (Line(points={{50,41},{50,58},{48,58}},
                                               color={0,0,127}));
  connect(TSet.y, conFan.u_s)
    annotation (Line(points={{79,70},{60,70}}, color={0,0,127}));
  connect(mFloSet.y, airIn.m_flow_in) annotation (Line(points={{-21,70},{-40,70},
          {-40,38},{-32,38}}, color={0,0,127}));
  connect(conFan.y, mFloSet.u)
    annotation (Line(points={{36,70},{2,70}},   color={0,0,127}));
  connect(ramAir.y, TAir.u2) annotation (Line(points={{-79,30},{-74,30},{-74,24},
          {-68,24}}, color={0,0,127}));
  connect(airNoi.y, TAir.u1) annotation (Line(points={{-79,70},{-74,70},{-74,36},
          {-68,36}}, color={0,0,127}));
  connect(TAir.y, airIn.T_in) annotation (Line(points={{-45,30},{-40,30},{-40,
          34},{-32,34}}, color={0,0,127}));
  connect(disDat.y[2],TSteMea. u) annotation (Line(points={{61,-60},{64,-60},{64,
          -80},{70,-80}},      color={0,0,127}));
  connect(disDat.y[1], watIn.m_flow_in) annotation (Line(points={{61,-60},{80,-60},
          {80,-22},{62,-22}}, color={0,0,127}));
    annotation(Icon(coordinateSystem(preserveAspectRatio = false,extent = {{-100.0,-100.0},{100.0,100.0}})),
        experiment(
      StopTime=86400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Subsystems/HeatExchangerAirWaterDistrict.mos"
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
Example model for air-water heat exchanger with a data table for the district load profile.
</p>
</html>"));
end HeatExchangerAirWaterDistrict;
