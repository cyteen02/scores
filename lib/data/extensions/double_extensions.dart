/*---------------------------------------------------------------------------
*
* Copyright (c) 2026 Paul Graves
* All Rights Reserved.
*
* You may not use, distribute and modify this code under any circumstances
*
* Created: 01/31/2026
*
*----------------------------------------------------------------------------*/


extension DoubleIsIntegerExtension on double {
  bool isInteger() {
    return this == this.roundToDouble();
  }
}

//---------------------------------------------------------------------------
