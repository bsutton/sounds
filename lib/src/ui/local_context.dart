/*
 * This file is part of Sounds.
 *
 *   Sounds is free software: you can redistribute it and/or modify
 *   it under the terms of the Lesser GNU General Public License
 *   version 3 (LGPL3) as published by the Free Software Foundation.
 *
 *   Sounds is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the Lesser GNU General Public License
 *   along with Sounds.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

///
class LocalContext extends StatefulWidget {
  final Widget Function(BuildContext context) _builder;

  ///
  const LocalContext(
      {Key? key, required Widget Function(BuildContext context) builder})
      : _builder = builder,
        super(key: key);

  @override
  LocalContextState createState() => LocalContextState();
}

///
class LocalContextState extends State<LocalContext> {
  @override
  Widget build(BuildContext context) {
    return widget._builder(context);
  }
}
