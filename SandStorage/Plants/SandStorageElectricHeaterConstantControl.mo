within SandStorage.Plants;
model SandStorageElectricHeaterConstantControl
  "Sand thermal energy storage plant with constant setpoint control at the particle heater"
   extends Buildings.BaseClasses.BaseIcon;
  // External ports
  // Diagnostics
   parameter Boolean show_T = false
    "= true, if actual temperature at port is computed"
    annotation (
      Dialog(tab="Advanced", group="Diagnostics"),
      HideResult=true);

  MediumWat.ThermodynamicState sta_a=
      MediumWat.setState_phX(port_a.p,
                          noEvent(inStream(port_a.h_outflow)),
                          noEvent(inStream(port_a.Xi_outflow)))
      if show_T "Medium properties in port_a";

  MediumWat.ThermodynamicState sta_b=
      MediumWat.setState_phX(port_b.p,
                          noEvent(port_b.h_outflow),
                          noEvent(port_b.Xi_outflow))
       if show_T "Medium properties in port_b";

  // Plant parameters
  package MediumSan = SandStorage.Media.SandPolynomial (
    T_default=1200+273.15);
  package MediumAir = Modelica.Media.Air.ReferenceAir.Air_pT;
  //Buildings.Media.Air;
  //Modelica.Media.Air.ReferenceAir.Air_pT;
  //Modelica.Media.Air.DryAirNasa;
  package MediumWat = Modelica.Media.Water.StandardWater (
            p_default=963197,
            T_default=180+273.15);
  parameter Modelica.Units.SI.MassFlowRate mWat_flow_nominal = 1.7;
  parameter Modelica.Units.SI.MassFlowRate mSan_flow_nominal = 19.81;
  parameter Modelica.Units.SI.MassFlowRate mAir_flow_nominal=14.63;
   // mSan_flow_nominal*cpSan_default/cpAir_default;
  parameter Modelica.Units.SI.Temperature TSanOut_nominal = 726.9+273.15;
  parameter Modelica.Units.SI.Temperature TSanIn_nominal = 1200+273.15;
  parameter Modelica.Units.SI.Temperature TAirOut_nominal = 1000+273.15;
  parameter Modelica.Units.SI.Temperature TAirIn_nominal = 238+273.15;
  parameter Modelica.Units.SI.Temperature TWatIn_nominal = 170+273.15;
    parameter Modelica.Units.SI.Temperature TWatOut_nominal =  180+273.15;
  parameter Modelica.Units.SI.AbsolutePressure pAirOut_nominal = 150000;
  parameter Modelica.Units.SI.AbsolutePressure pSte_nominal = 963197;
  final parameter Modelica.Units.SI.SpecificEnthalpy hWatOut_nominal=
    MediumWat.specificEnthalpy(
      MediumWat.setState_pTX(
        p=pSte_nominal,
        T=TWatOut_nominal,
        X=MediumWat.X_default));
  parameter Modelica.Units.SI.PressureDifference dp_nominal = 6000;
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
    T_start=TSanIn_nominal,
    redeclare package MediumHex = MediumAir,
    hHex_a=hHex_a,
    hHex_b=hHex_b,
    Q_flow_nominal=QAir_flow_nominal,
    TTan_nominal=TSanIn_nominal,
    THex_nominal=TAirIn_nominal,
    mHex_flow_nominal=mAir_flow_nominal)
    "Particle tank with heat exchanger"
    annotation (Placement(transformation(extent={{50,44},{70,64}})));

  SandStorage.Equipment.ParticleConveyor mov(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    h=20) "Mover" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-40,30})));
  Buildings.Fluid.HeatExchangers.HeaterCooler_u hea(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    show_T=true,
    dp_nominal=0,
    Q_flow_nominal=3*QSan_flow_nominal)
    "Particle heater"
    annotation (Placement(transformation(extent={{-30,44},{-10,64}})));
  Modelica.Blocks.Logical.Hysteresis staMov(uLow=0, uHigh=1e-4,
    pre_y_start=true)
    "Mover state"
    annotation (Placement(transformation(extent={{-110,0},{-90,20}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(realTrue=
        mSan_flow_nominal)
    annotation (Placement(transformation(extent={{-80,0},{-60,20}})));
  SandStorage.BaseClasses.Boundary_pT_highP pRefSan(redeclare package Medium =
                       MediumSan, nPorts=1) "Reference pressure sand"
    annotation (Placement(transformation(extent={{124,-4},{116,4}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTSanOut(redeclare package
      Medium = MediumSan, m_flow_nominal=mSan_flow_nominal)
    "Sand leaving the tank"
    annotation (Placement(transformation(extent={{78,44},{98,64}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTSanIn(redeclare package Medium =
        MediumSan, m_flow_nominal=mSan_flow_nominal) "Sand entering the tank"
    annotation (Placement(transformation(extent={{0,44},{20,64}})));
  Buildings.Fluid.Sensors.SpecificEnthalpyTwoPort hSteSup(redeclare package
      Medium = MediumWat, m_flow_nominal=mWat_flow_nominal)
    "h  sensor steam supply"
    annotation (Placement(transformation(extent={{60,-130},{80,-110}})));
  SandStorage.Equipment.HeatExchanger hex(
    m1_flow_nominal=mWat_flow_nominal,
    m2_flow_nominal=mAir_flow_nominal,
    show_T=true,
    dp1_nominal=dp_nominal,
    dp2_nominal=dp_nominal,
    redeclare package MediumWat = MediumWat,
    redeclare package MediumAir = MediumAir) "Heat exchanger" annotation (
      Placement(transformation(
        extent={{-40,-26},{-20,-46}})));
  Buildings.Controls.OBC.CDL.Continuous.PID conFan(
    y(start=0.1),
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    k=1,
    Ti(displayUnit="s") = 120) "Fan control"
    annotation (Placement(transformation(extent={{80,-80},{60,-60}})));
  Modelica.Blocks.Sources.Constant uni(k=1) "Unitary"
    annotation (Placement(transformation(extent={{120,-80},{100,-60}})));
  Modelica.Blocks.Math.Gain mFloSet(k=mAir_flow_nominal)
    "Mass flow setpoint for air"
    annotation (Placement(transformation(extent={{40,-80},{20,-60}})));
  Buildings.Fluid.Movers.FlowControlled_m_flow fan(redeclare package Medium =
        MediumAir,
    T_start=TAirOut_nominal,
                   m_flow_nominal=mAir_flow_nominal,
    riseTime=60,
    dp_nominal=24000,
    m_flow_start=mAir_flow_nominal*0.1)
    annotation (Placement(transformation(extent={{20,-20},{0,-40}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    p(start=MediumWat.p_default),
    redeclare final package Medium = MediumWat,
    m_flow(max=0),
    h_outflow(start=MediumWat.h_default))
    "Fluid connector b (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{150,-130},{130,-110}}),
        iconTransformation(extent={{88,-10},{108,10}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    p(start=MediumWat.p_default),
    redeclare final package Medium = MediumWat,
    m_flow(min= 0),
    h_outflow(start=MediumWat.h_default))
    "Fluid connector a (positive design flow direction is from port_a to port_b)"
    annotation (Placement(transformation(extent={{-150,-130},{-130,-110}}),
        iconTransformation(extent={{-110,-10},{-90,10}})));
  Buildings.Controls.OBC.CDL.Interfaces.RealOutput P(final unit="W")
    "Plant power demand" annotation (Placement(transformation(extent={{140,60},
            {180,100}}), iconTransformation(extent={{100,40},{140,80}})));
    //    annotation (Placement(transformation(extent={{140,60},{180,100}}),
    //  iconTransformation(extent={{100,20},{180,100}})));
  Modelica.Blocks.Math.Add3 sumPow
    annotation (Placement(transformation(extent={{110,70},{130,90}})));
  Modelica.Blocks.Math.Gain hRel(k=1/hWatOut_nominal) "Relative h" annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={70,-94})));
  Buildings.Controls.OBC.CDL.Continuous.PID con(
    controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    k=5,
    Ti(displayUnit="s") = 120) "Control"
    annotation (Placement(transformation(extent={{-80,80},{-60,60}})));
  Modelica.Blocks.Math.Gain TRel(k=1/TSanIn_nominal)
                                                   "Relative temperature"
    annotation (Placement(transformation(extent={{-120,90},{-100,110}})));
  Modelica.Blocks.Sources.Constant uni1(k=1)
                                            "Unitary"
    annotation (Placement(transformation(extent={{-120,60},{-100,80}})));
equation
  connect(staMov.y, booToRea.u)
    annotation (Line(points={{-89,10},{-82,10}},
                                               color={255,0,255}));
  connect(mov.port_b, hea.port_a)
    annotation (Line(points={{-40,40},{-40,54},{-30,54}},
                                                        color={244,125,35},
      thickness=0.5));
  connect(hea.port_b, senTSanIn.port_a)
    annotation (Line(points={{-10,54},{0,54}}, color={244,125,35},
      thickness=0.5));
  connect(senTSanIn.port_b, tan.port_a) annotation (Line(points={{20,54},{50,54}},
                                            color={244,125,35},
      thickness=0.5));
  connect(tan.port_b, senTSanOut.port_a)
    annotation (Line(points={{70,54},{78,54}}, color={244,125,35},
      thickness=0.5));
  connect(senTSanOut.port_b, mov.port_a) annotation (Line(points={{98,54},{110,54},
          {110,0},{-40,0},{-40,20}},        color={244,125,35},
      thickness=0.5));
  connect(uni.y, conFan.u_s) annotation (Line(
      points={{99,-70},{82,-70}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(conFan.y, mFloSet.u)
    annotation (Line(points={{58,-70},{42,-70}},   color={0,0,127},
      pattern=LinePattern.Dash));
  connect(hex.port_b1, hSteSup.port_a) annotation (Line(
      points={{-20,-42},{-14,-42},{-14,-120},{60,-120}},
      color={238,46,47},
      thickness=0.5));
  connect(fan.port_b, hex.port_a2)
    annotation (Line(points={{0,-30},{-20,-30}}, color={62,188,62},
      thickness=0.5));
  connect(pRefSan.ports[1], mov.port_a) annotation (Line(points={{116,0},{-40,0},
          {-40,20}},      color={244,125,35},
      thickness=0.5));
  connect(tan.portHex_b, fan.port_a) annotation (Line(
      points={{50,46},{38,46},{38,-30},{20,-30}},
      color={62,188,62},
      thickness=0.5));
  connect(hex.port_b2, tan.portHex_a) annotation (Line(
      points={{-40,-30},{-50,-30},{-50,-10},{34,-10},{34,50.2},{50,50.2}},
      color={62,188,62},
      thickness=0.5));
  connect(port_a, hex.port_a1) annotation (Line(
      points={{-140,-120},{-50,-120},{-50,-42},{-40,-42}},
      color={238,46,47},
      thickness=0.5));
  connect(hSteSup.port_b, port_b) annotation (Line(
      points={{80,-120},{140,-120}},
      color={238,46,47},
      thickness=0.5));
  connect(booToRea.y, mov.m_flow_in)
    annotation (Line(points={{-58,10},{-35,10},{-35,18}}, color={0,0,127},
      pattern=LinePattern.Dash));

  connect(mov.P, sumPow.u1) annotation (Line(
      points={{-48,41},{-48,88},{108,88}},
      color={0,0,127},
      pattern=LinePattern.Dot));
  connect(hea.Q_flow, sumPow.u2) annotation (Line(
      points={{-9,60},{0,60},{0,80},{108,80}},
      color={0,0,127},
      pattern=LinePattern.Dot));
  connect(sumPow.y, P) annotation (Line(
      points={{131,80},{136,80},{136,80},{160,80}},
      color={0,0,127},
      pattern=LinePattern.Dot));
  connect(sumPow.u3, fan.P) annotation (Line(
      points={{108,72},{100,72},{100,-46},{-6,-46},{-6,-39},{-1,-39}},
      color={0,0,127},
      pattern=LinePattern.Dot));
  connect(mFloSet.y, fan.m_flow_in)
    annotation (Line(points={{19,-70},{10,-70},{10,-42}}, color={0,0,127}));
  connect(conFan.u_m, hRel.y)
    annotation (Line(points={{70,-82},{70,-87.4}}, color={0,0,127}));
  connect(hSteSup.h_out, hRel.u)
    annotation (Line(points={{70,-109},{70,-101.2}}, color={0,0,127}));
  connect(uni1.y, con.u_s) annotation (Line(
      points={{-99,70},{-82,70}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(senTSanIn.T, TRel.u) annotation (Line(
      points={{10,65},{10,120},{-130,120},{-130,100},{-122,100}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(TRel.y, con.u_m) annotation (Line(
      points={{-99,100},{-70,100},{-70,82}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(con.y, hea.u) annotation (Line(
      points={{-58,70},{-54,70},{-54,60},{-32,60}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(staMov.u, con.y) annotation (Line(
      points={{-112,10},{-120,10},{-120,48},{-54,48},{-54,70},{-58,70}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,100},{100,-100}},
          lineColor={0,0,127},
          fillColor={255,255,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{60,-4},{100,4}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={238,46,47},
          fillPattern=FillPattern.Solid,
          visible=have_coo),
        Rectangle(
          extent={{-100,-4},{-60,4}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid,
          visible=have_coo),
        Rectangle(
          extent={{-70,70},{70,-70}},
          lineColor={27,0,55},
          fillColor={170,213,255},
          fillPattern=FillPattern.Solid)}),                      Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-140,-140},{140,120}})),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end SandStorageElectricHeaterConstantControl;
