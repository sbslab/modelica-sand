within SandStorage.Equipment;
model ParticleConveyor
  "Model of a particle conveyor for general purposes"
  extends Buildings.Fluid.Interfaces.PartialTwoPortInterface(
    final allowFlowReversal=false);
  parameter Real eta=0.9 "Total efficiency of conveyor";
  parameter Modelica.Units.SI.Length h(min=0)
    "Vertical lift height by the conveyor";
  // Classes used to implement the filtered speed
  parameter Boolean use_inputFilter=true
    "= true, if speed is filtered with a 2nd order CriticalDamping filter"
    annotation(Dialog(tab="Dynamics", group="Filtered speed"));
  parameter Modelica.Units.SI.Time riseTime=60
    "Rise time of the filter (time to reach 99.6 % of the speed)" annotation (
      Dialog(
      tab="Dynamics",
      group="Filtered speed",
      enable=use_inputFilter));
  parameter Modelica.Blocks.Types.Init init=Modelica.Blocks.Types.Init.InitialOutput
    "Type of initialization (no init/steady state/initial state/initial output)"
    annotation(Dialog(tab="Dynamics", group="Filtered speed",enable=use_inputFilter));
  final parameter Modelica.Units.SI.Acceleration g=Modelica.Constants.g_n
    "Constant gravity acceleration";
  final parameter Modelica.Units.SI.Frequency fCut=5/(2*Modelica.Constants.pi*
      riseTime) "Cut-off frequency of filter";
  Modelica.Blocks.Interfaces.RealOutput P(
    quantity="Power",
    final unit="W")
    "Electrical power consumed"
    annotation (Placement(transformation(extent={{100,80},{120,100}}),
        iconTransformation(extent={{100,70},{120,90}})));
  Modelica.Blocks.Interfaces.RealInput m_flow_in(
    final unit="kg/s",
    nominal=m_flow_nominal)
    "Prescribed mass flow rate"
    annotation (Placement(transformation(
        extent={{-140,-70},{-100,-30}}), iconTransformation(extent={{-140,-70},{
            -100,-30}})));
  Buildings.Fluid.Movers.BaseClasses.IdealSource mov(
    redeclare final package Medium = Medium,
    final allowFlowReversal=allowFlowReversal,
    final m_flow_small=m_flow_small,
    final show_T=show_T,
    show_V_flow=false,
    final control_m_flow=true)
    "Mover"
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
protected
  Buildings.Fluid.BaseClasses.ActuatorFilter filter(
    final n=2,
    final f=fCut,
    final normalized=true,
    final initType=init) if use_inputFilter
    "Second order filter to approximate dynamics of pump speed, and to improve numerics"
    annotation (Placement(transformation(extent={{-60,41},{-40,60}})));
equation
  //port_a.p - port_b.p = 0;
  P = m_flow*g*h/eta;
  //port_b.h_outflow = inStream(port_a.h_outflow);
 // port_a.h_outflow = instream(port_b.h_outflow);
  connect(port_a, mov.port_a)
    annotation (Line(points={{-100,0},{-10,0}}, color={0,127,255}));
  connect(mov.port_b, port_b)
    annotation (Line(points={{10,0},{100,0}}, color={0,127,255}));
  if use_inputFilter then
  connect(m_flow_in, filter.u)
   annotation (Line(points={{-120,-50},{-80,-50},{-80,50.5},{-62,50.5}},
     color={0,0,127}));
  connect(filter.y, mov.m_flow_in)
    annotation (Line(points={{-39,50.5},{-6,50.5},{-6,8}}, color={0,0,127}));
  else
  connect(m_flow_in, mov.m_flow_in)
    annotation (Line(points={{-120,-50},{-80,-50},{-80,30},{-6,30},{-6,8}},
      color={0,0,127}));
  end if;
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-100,62},{100,-20}},
          lineColor={0,0,0},
          fillColor={81,100,223},
          fillPattern=FillPattern.HorizontalCylinder),
        Rectangle(
          extent={{-100,6},{100,-6}},
          lineColor={0,0,0},
          fillColor={0,0,0},
          fillPattern=FillPattern.Solid),
        Line(
          points={{-60,70},{60,70}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{60,70},{20,90}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{-60,46},{-60,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{-60,46},{-80,38},{-80,12},{-80,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{-10,46},{-10,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{-10,46},{-30,38},{-30,12},{-30,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{42,46},{42,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{42,46},{22,38},{22,12},{22,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{90,46},{90,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Line(
          points={{90,46},{70,38},{70,12},{70,6}},
          color={0,0,0},
          thickness=0.5,
          smooth=Smooth.Bezier),
        Text(
          visible=use_inputFilter,
          extent={{-88,-28},{-46,-74}},
          textColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          textString="M",
          textStyle={TextStyle.Bold}),
        Rectangle(
          visible=use_inputFilter,
          extent={{-100,-80},{-34,-20}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Ellipse(
          visible=use_inputFilter,
          extent={{-100,-20},{-34,-80}},
          lineColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid),
        Text(
          visible=use_inputFilter,
          extent={{-88,-28},{-46,-74}},
          textColor={0,0,0},
          fillColor={135,135,135},
          fillPattern=FillPattern.Solid,
          textString="M",
          textStyle={TextStyle.Bold})}),
                                   Diagram(coordinateSystem(preserveAspectRatio=
           false)),
    Documentation(info="<html>
</html>", revisions="<html>
<ul>
<li>
February 15, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end ParticleConveyor;
