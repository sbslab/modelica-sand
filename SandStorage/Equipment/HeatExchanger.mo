within SandStorage.Equipment;
model HeatExchanger
"Simple heat exchanger model with a constant effectiveness that 
  is suitable for water phase change. Side 1 = water, side 2 = air"
  extends Buildings.Fluid.HeatExchangers.BaseClasses.PartialEffectiveness(
    redeclare final package Medium1 = MediumWat,
    redeclare final package Medium2 = MediumAir,
    sensibleOnly1 = false,
    sensibleOnly2 = true,
    final allowFlowReversal1 = false,
    final allowFlowReversal2 = false,
    final prescribedHeatFlowRate1=false,
    final prescribedHeatFlowRate2=false,
    Q1_flow = eps * QMax_flow,
    Q2_flow = -Q1_flow,
    mWat1_flow = 0,
    mWat2_flow = 0);
  replaceable package MediumWat = Modelica.Media.Water.StandardWater "Water medium";
  replaceable package MediumAir = Buildings.Media.Air "Air medium";
  parameter Modelica.Units.SI.Efficiency eps(max=1) = 0.8
    "Heat exchanger effectiveness";
  annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
        Rectangle(
          extent={{-52,74},{50,42}},
          lineColor={255,0,0},
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-52,-42},{50,-74}},
          lineColor={0,255,0},
          fillColor={0,255,0},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-52,-42},{50,-74}},
          textColor={0,0,0},
          textString="air"),
        Text(
          extent={{-52,74},{50,42}},
          textColor={0,0,0},
          textString="water"),
        Line(points={{-40,34},{40,34},{20,24}}, color={255,0,0}),
        Line(points={{40,-34},{-40,-34},{-20,-24}}, color={0,255,0})}),
       Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Model for a heat exchanger with constant effectiveness involving water phase change.
</p>
</html>"));
end HeatExchanger;
