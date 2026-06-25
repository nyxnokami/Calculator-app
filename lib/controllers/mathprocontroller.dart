import 'package:flutter/material.dart';
import 'dart:math' as math;

class MathProController {
  final ValueNotifier<String> display = ValueNotifier('0');
  final ValueNotifier<String> expression = ValueNotifier('');
  final ValueNotifier<List<String>> history = ValueNotifier([]);

  double _operand = 0;
  String _op = '';
  bool _fresh = false;

  void digit(String d) {
    if (_fresh) { display.value=d; _fresh=false; }
    else { display.value = display.value=='0' ? d : display.value+d; }
  }

  void dot() {
    if (_fresh) { display.value='0.'; _fresh=false; return; }
    if (!display.value.contains('.')) display.value += '.';
  }

  void oper(String op) {
    _operand=double.tryParse(display.value)??0;
    _op=op; expression.value='${display.value} $op'; _fresh=true;
  }

  void equals() {
    if (_op.isEmpty) return;
    final b=double.tryParse(display.value)??0;
    late double r;
    switch (_op) {
      case '+': r=_operand+b; break;
      case '−': r=_operand-b; break;
      case '×': r=_operand*b; break;
      case '÷': r=b!=0?_operand/b:double.nan; break;
      default: r=b;
    }
    expression.value += ' ${display.value} =';
    final result = _fmt(r);
    history.value = ['${expression.value}', ...history.value.take(19)];
    display.value=result; _op=''; _fresh=true;
  }

  void clear() {
    display.value='0'; expression.value=''; _operand=0; _op=''; _fresh=false;
  }

  void sign() {
    if (display.value=='0'||display.value=='Error') return;
    display.value=display.value.startsWith('-')
        ? display.value.substring(1) : '-${display.value}';
  }

  void pct() {
    final v=double.tryParse(display.value)??0; display.value=_fmt(v/100);
  }

  void back() {
    if (display.value=='Error'){display.value='0';return;}
    if (display.value.length<=1){display.value='0';return;}
    display.value=display.value.substring(0,display.value.length-1);
    if (display.value=='-') display.value='0';
  }

  
  void sci(String fn) {
    final x = double.tryParse(display.value) ?? 0;
    late double r;
    switch (fn) {
      case 'sin':  r = _sinD(x); break;
      case 'cos':  r = _cosD(x); break;
      case 'tan':  r = _tanD(x); break;
      case 'asin': r = _asinD(x); break;
      case 'acos': r = _acosD(x); break;
      case 'atan': r = _atanD(x); break;
      case 'sinh': r = (_ex(x)-_ex(-x))/2; break;
      case 'cosh': r = (_ex(x)+_ex(-x))/2; break;
      case 'tanh':
        final s=(_ex(x)-_ex(-x))/2; final c=(_ex(x)+_ex(-x))/2;
        r = c!=0?s/c:double.nan; break;
      case 'log':  r = x>0 ? math.log(x)/math.ln10 : double.nan; break;
      case 'ln':   r = x>0 ? math.log(x) : double.nan; break;
      case 'sqrt': r = x>=0 ? math.sqrt(x) : double.nan; break;
      case 'x²': r = x*x; break;
      case 'x³': r = x*x*x; break;
      case '1/x':  r = x!=0 ? 1/x : double.nan; break;
      case '|x|':  r = x.abs(); break;
      case 'n!':
        if (x<0||x!=x.floorToDouble()){display.value='Error';return;}
        r=_fact(x.toInt()).toDouble(); break;
      case 'π': display.value=math.pi.toString(); _fresh=true; return;
      case 'e':   display.value=math.e.toString(); _fresh=true; return;
      default: return;
    }
    display.value=_fmt(r); _fresh=true;
  }

  void combo(String type) {
    if (_op=='nPr'||_op=='nCr') {
      final r=double.tryParse(display.value)??0;
      final ni=_operand.toInt(); final ri=r.toInt();
      if (_operand<0||r<0||r>_operand){display.value='Error';_op='';return;}
      final nFact=_fact(ni).toDouble(); final nrFact=_fact(ni-ri).toDouble();
      display.value = type=='nPr'?_fmt(nFact/nrFact):_fmt(nFact/(nrFact*_fact(ri)));
      _op=''; _fresh=true;
    } else {
      _operand=double.tryParse(display.value)??0;
      _op=type; expression.value='${display.value} $type'; _fresh=true;
    }
  }

  double _sinD(double d) => math.sin(d*math.pi/180);
  double _cosD(double d) => math.cos(d*math.pi/180);
  double _tanD(double d) => math.tan(d*math.pi/180);
  double _asinD(double d) => math.asin(d)*180/math.pi;
  double _acosD(double d) => math.acos(d)*180/math.pi;
  double _atanD(double d) => math.atan(d)*180/math.pi;
  double _ex(double x) => math.exp(x);
  int _fact(int n) => n<=1?1:n*_fact(n-1);


  String _fmt(double r) {
    if (r.isNaN||r.isInfinite) return 'Error';
    if (r==r.truncateToDouble()&&r.abs()<1e15) return r.toInt().toString();
    return r.toStringAsFixed(10).replaceAll(RegExp(r'0+$'),'').replaceAll(RegExp(r'\.$'),'');
  }

  void dispose() { display.dispose(); expression.dispose(); history.dispose(); }
}
