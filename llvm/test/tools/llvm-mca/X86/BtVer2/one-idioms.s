# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -timeline -register-file-stats -iterations=1 < %s | FileCheck %s

# These are dependency-breaking one-idioms.
# Much like zero-idioms, but they produce ones, and do consume resources.

pcmpeqb   %mm2, %mm2
pcmpeqd   %mm2, %mm2
# pcmpeqq %mm2, %mm2 # invalid operand for instruction
pcmpeqw   %mm2, %mm2

pcmpeqb   %xmm2, %xmm2
pcmpeqd   %xmm2, %xmm2
pcmpeqq   %xmm2, %xmm2
pcmpeqw   %xmm2, %xmm2

vpcmpeqb  %xmm3, %xmm3, %xmm3
vpcmpeqd  %xmm3, %xmm3, %xmm3
vpcmpeqq  %xmm3, %xmm3, %xmm3
vpcmpeqw  %xmm3, %xmm3, %xmm3

vpcmpeqb  %xmm3, %xmm3, %xmm5
vpcmpeqd  %xmm3, %xmm3, %xmm5
vpcmpeqq  %xmm3, %xmm3, %xmm5
vpcmpeqw  %xmm3, %xmm3, %xmm5

# FIXME: their handling is broken in llvm-mca.

# CHECK:      Iterations:        1
# CHECK-NEXT: Instructions:      15
# CHECK-NEXT: Total Cycles:      12
# CHECK-NEXT: Dispatch Width:    2
# CHECK-NEXT: IPC:               1.25
# CHECK-NEXT: Block RThroughput: 7.5

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     0.50                        pcmpeqb	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        pcmpeqd	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        pcmpeqw	%mm2, %mm2
# CHECK-NEXT:  1      1     0.50                        pcmpeqb	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        pcmpeqd	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        pcmpeqq	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        pcmpeqw	%xmm2, %xmm2
# CHECK-NEXT:  1      1     0.50                        vpcmpeqb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpeqd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpeqq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpeqw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  1      1     0.50                        vpcmpeqb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpcmpeqd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpcmpeqq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  1      1     0.50                        vpcmpeqw	%xmm3, %xmm3, %xmm5

# CHECK:      Register File statistics:
# CHECK-NEXT: Total number of mappings created:    15
# CHECK-NEXT: Max number of mappings used:         8

# CHECK:      *  Register File #1 -- JFpuPRF:
# CHECK-NEXT:    Number of physical registers:     72
# CHECK-NEXT:    Total number of mappings created: 15
# CHECK-NEXT:    Max number of mappings used:      8

# CHECK:      *  Register File #2 -- JIntegerPRF:
# CHECK-NEXT:    Number of physical registers:     64
# CHECK-NEXT:    Total number of mappings created: 0
# CHECK-NEXT:    Max number of mappings used:      0

# CHECK:      Resources:
# CHECK-NEXT: [0]   - JALU0
# CHECK-NEXT: [1]   - JALU1
# CHECK-NEXT: [2]   - JDiv
# CHECK-NEXT: [3]   - JFPA
# CHECK-NEXT: [4]   - JFPM
# CHECK-NEXT: [5]   - JFPU0
# CHECK-NEXT: [6]   - JFPU1
# CHECK-NEXT: [7]   - JLAGU
# CHECK-NEXT: [8]   - JMul
# CHECK-NEXT: [9]   - JSAGU
# CHECK-NEXT: [10]  - JSTC
# CHECK-NEXT: [11]  - JVALU0
# CHECK-NEXT: [12]  - JVALU1
# CHECK-NEXT: [13]  - JVIMUL

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]
# CHECK-NEXT:  -      -      -      -      -     7.00   8.00    -      -      -      -     7.00   8.00    -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     pcmpeqb	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pcmpeqd	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pcmpeqw	%mm2, %mm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     pcmpeqb	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     pcmpeqd	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pcmpeqq	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     pcmpeqw	%xmm2, %xmm2
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpeqb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpeqd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpcmpeqq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpeqw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpcmpeqb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpeqd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -     1.00    -      -      -      -      -     1.00    -      -     vpcmpeqq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT:  -      -      -      -      -      -     1.00    -      -      -      -      -     1.00    -     vpcmpeqw	%xmm3, %xmm3, %xmm5

# CHECK:      Timeline view:
# CHECK-NEXT:                     01
# CHECK-NEXT: Index     0123456789

# CHECK:      [0,0]     DeER .    ..   pcmpeqb	%mm2, %mm2
# CHECK-NEXT: [0,1]     D=eER.    ..   pcmpeqd	%mm2, %mm2
# CHECK-NEXT: [0,2]     .D=eER    ..   pcmpeqw	%mm2, %mm2
# CHECK-NEXT: [0,3]     .DeE-R    ..   pcmpeqb	%xmm2, %xmm2
# CHECK-NEXT: [0,4]     . DeE-R   ..   pcmpeqd	%xmm2, %xmm2
# CHECK-NEXT: [0,5]     . D=eER   ..   pcmpeqq	%xmm2, %xmm2
# CHECK-NEXT: [0,6]     .  D=eER  ..   pcmpeqw	%xmm2, %xmm2
# CHECK-NEXT: [0,7]     .  DeE-R  ..   vpcmpeqb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,8]     .   DeE-R ..   vpcmpeqd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,9]     .   D=eER ..   vpcmpeqq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,10]    .    D=eER..   vpcmpeqw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: [0,11]    .    D==eER.   vpcmpeqb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,12]    .    .D=eER.   vpcmpeqd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,13]    .    .D==eER   vpcmpeqq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: [0,14]    .    . D=eER   vpcmpeqw	%xmm3, %xmm3, %xmm5

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     1     1.0    1.0    0.0       pcmpeqb	%mm2, %mm2
# CHECK-NEXT: 1.     1     2.0    0.0    0.0       pcmpeqd	%mm2, %mm2
# CHECK-NEXT: 2.     1     2.0    0.0    0.0       pcmpeqw	%mm2, %mm2
# CHECK-NEXT: 3.     1     1.0    1.0    1.0       pcmpeqb	%xmm2, %xmm2
# CHECK-NEXT: 4.     1     1.0    0.0    1.0       pcmpeqd	%xmm2, %xmm2
# CHECK-NEXT: 5.     1     2.0    0.0    0.0       pcmpeqq	%xmm2, %xmm2
# CHECK-NEXT: 6.     1     2.0    0.0    0.0       pcmpeqw	%xmm2, %xmm2
# CHECK-NEXT: 7.     1     1.0    1.0    1.0       vpcmpeqb	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 8.     1     1.0    0.0    1.0       vpcmpeqd	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 9.     1     2.0    0.0    0.0       vpcmpeqq	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 10.    1     2.0    0.0    0.0       vpcmpeqw	%xmm3, %xmm3, %xmm3
# CHECK-NEXT: 11.    1     3.0    0.0    0.0       vpcmpeqb	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 12.    1     2.0    0.0    0.0       vpcmpeqd	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 13.    1     3.0    1.0    0.0       vpcmpeqq	%xmm3, %xmm3, %xmm5
# CHECK-NEXT: 14.    1     2.0    1.0    0.0       vpcmpeqw	%xmm3, %xmm3, %xmm5
