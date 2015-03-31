#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim: set fenc=utf-8 ai ts=4 sw=4 sts=4 et:

import math

N_ROTATIONS = 64
THRUST = 0.08
MISSILE = 0.9

def f_to_hex(f):
    i = int(f * 0x100)
    if i < 0:
        i = 0x10000 + i
    if i > 0xFFFF:
        i %= 0xFFFF
    return "$%08X" % i


def draw_sine_table(name, scale):
    print("LABEL Sine_{}".format(name))

    d = 0.0
    end = 360.0
    step = 360.0 / N_ROTATIONS

    for i in range(N_ROTATIONS):
        f = math.sin(math.radians(d)) * scale

        rd = "%7.3f" % d
        h = f_to_hex(f)

        print("\t.word {} ; d = {}".format(h, rd))

        d += step

    print()



def main():
    print("CONST N_ROTATIONS,", N_ROTATIONS)
    print()

    draw_sine_table("Thrust", THRUST)
    draw_sine_table("Missile", THRUST)

if __name__ == '__main__':
    main()

