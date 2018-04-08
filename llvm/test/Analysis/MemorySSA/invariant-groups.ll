; RUN: opt -basicaa -print-memoryssa -verify-memoryssa -analyze < %s 2>&1 | FileCheck %s
;
; Currently, MemorySSA doesn't support invariant groups. So, we should ignore
; launder.invariant.group intrinsics entirely. We'll need to pay attention to
; them when/if we decide to support invariant groups.

@g = external global i32

define i32 @foo(i32* %a) {
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i32 0
  store i32 0, i32* %a, align 4, !invariant.group !0

; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: store i32 1
  store i32 1, i32* @g, align 4

  %1 = bitcast i32* %a to i8*
; CHECK:  3 = MemoryDef(2)
; CHECK-NEXT: %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)
  %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)
  %a32 = bitcast i8* %a8 to i32*

; This have to be MemoryUse(2), because we can't skip the barrier based on
; invariant.group.
; CHECK: MemoryUse(2)
; CHECK-NEXT: %2 = load i32
  %2 = load i32, i32* %a32, align 4, !invariant.group !0
  ret i32 %2
}

define i32 @skipBarrier(i32* %a) {
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i32 0
  store i32 0, i32* %a, align 4, !invariant.group !0

  %1 = bitcast i32* %a to i8*
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)
  %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)  
  %a32 = bitcast i8* %a8 to i32*

; We can skip the barrier only if the "skip" is not based on !invariant.group.
; CHECK: MemoryUse(1)
; CHECK-NEXT: %2 = load i32
  %2 = load i32, i32* %a32, align 4, !invariant.group !0
  ret i32 %2
}

define i32 @skipBarrier2(i32* %a) {

; CHECK: MemoryUse(liveOnEntry)
; CHECK-NEXT: %v = load i32
  %v = load i32, i32* %a, align 4, !invariant.group !0

  %1 = bitcast i32* %a to i8*
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)
  %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)
  %a32 = bitcast i8* %a8 to i32*

; We can skip the barrier only if the "skip" is not based on !invariant.group.
; CHECK: MemoryUse(liveOnEntry)
; CHECK-NEXT: %v2 = load i32
  %v2 = load i32, i32* %a32, align 4, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: store i32 1
  store i32 1, i32* @g, align 4

; CHECK: MemoryUse(liveOnEntry)
; CHECK-NEXT: %v3 = load i32
  %v3 = load i32, i32* %a32, align 4, !invariant.group !0
  %add = add nsw i32 %v2, %v3
  %add2 = add nsw i32 %add, %v
  ret i32 %add2
}

define i32 @handleInvariantGroups(i32* %a) {
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i32 0
  store i32 0, i32* %a, align 4, !invariant.group !0

; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: store i32 1
  store i32 1, i32* @g, align 4
  %1 = bitcast i32* %a to i8*
; CHECK: 3 = MemoryDef(2)
; CHECK-NEXT: %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)
  %a8 = call i8* @llvm.launder.invariant.group.p0i8(i8* %1)
  %a32 = bitcast i8* %a8 to i32*

; CHECK: MemoryUse(2)
; CHECK-NEXT: %2 = load i32
  %2 = load i32, i32* %a32, align 4, !invariant.group !0

; CHECK: 4 = MemoryDef(3)
; CHECK-NEXT: store i32 2
  store i32 2, i32* @g, align 4

; CHECK: MemoryUse(2)
; CHECK-NEXT: %3 = load i32
  %3 = load i32, i32* %a32, align 4, !invariant.group !0
  %add = add nsw i32 %2, %3
  ret i32 %add
}

define i32 @loop(i1 %a) {
entry:
  %0 = alloca i32, align 4
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i32 4
  store i32 4, i32* %0, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: call void @clobber
  call void @clobber(i32* %0)
  br i1 %a, label %Loop.Body, label %Loop.End

Loop.Body:
; CHECK: MemoryUse(1)
; CHECK-NEXT: %1 = load i32
  %1 = load i32, i32* %0, !invariant.group !0
  br i1 %a, label %Loop.End, label %Loop.Body

Loop.End:
; CHECK: MemoryUse(1)
; CHECK-NEXT: %2 = load
  %2 = load i32, i32* %0, align 4, !invariant.group !0
  br i1 %a, label %Ret, label %Loop.Body

Ret:
  ret i32 %2
}

define i8 @loop2(i8* %p) {
entry:
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i8
  store i8 4, i8* %p, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: call void @clobber
  call void @clobber8(i8* %p)

; CHECK: 3 = MemoryDef(2)
; CHECK-NEXT: %after = call i8* @llvm.launder.invariant.group.p0i8(i8* %p)
  %after = call i8* @llvm.launder.invariant.group.p0i8(i8* %p)
  br i1 undef, label %Loop.Body, label %Loop.End

Loop.Body:
; 5 = MemoryPhi({entry,3},{Loop.Body,4},{Loop.End,6})
; CHECK: MemoryUse(6)
; CHECK-NEXT: %0 = load i8
  %0 = load i8, i8* %after, !invariant.group !0

; CHECK: MemoryUse(1)
; CHECK-NEXT: %1 = load i8
  %1 = load i8, i8* %p, !invariant.group !0

; CHECK: 4 = MemoryDef(6)
  store i8 4, i8* %after, !invariant.group !0

  br i1 undef, label %Loop.End, label %Loop.Body

Loop.End:
; 6 = MemoryPhi({entry,3},{Loop.Body,4})
; CHECK: MemoryUse(5)
; CHECK-NEXT: %2 = load
  %2 = load i8, i8* %after, align 4, !invariant.group !0

; CHECK: MemoryUse(1)
; CHECK-NEXT: %3 = load
  %3 = load i8, i8* %p, align 4, !invariant.group !0
  br i1 undef, label %Ret, label %Loop.Body

Ret:
  ret i8 %3
}


define i8 @loop3(i8* %p) {
entry:
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i8
  store i8 4, i8* %p, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: call void @clobber
  call void @clobber8(i8* %p)

; CHECK: 3 = MemoryDef(2)
; CHECK-NEXT: %after = call i8* @llvm.launder.invariant.group.p0i8(i8* %p)
  %after = call i8* @llvm.launder.invariant.group.p0i8(i8* %p)
  br i1 undef, label %Loop.Body, label %Loop.End

Loop.Body:
; CHECK: 8 = MemoryPhi({entry,3},{Loop.Body,4},{Loop.next,5},{Loop.End,6})
; CHECK: MemoryUse(8)
; CHECK-NEXT: %0 = load i8
  %0 = load i8, i8* %after, !invariant.group !0

; CHECK: 4 = MemoryDef(8)
; CHECK-NEXT: call void @clobber8
  call void @clobber8(i8* %after)

; CHECK: MemoryUse(8)
; CHECK-NEXT: %1 = load i8
  %1 = load i8, i8* %after, !invariant.group !0

  br i1 undef, label %Loop.next, label %Loop.Body
Loop.next:
; CHECK: 5 = MemoryDef(4)
; CHECK-NEXT: call void @clobber8
  call void @clobber8(i8* %after)

; CHECK: MemoryUse(8)
; CHECK-NEXT: %2 = load i8
  %2 = load i8, i8* %after, !invariant.group !0

  br i1 undef, label %Loop.End, label %Loop.Body

Loop.End:
; CHECK: 7 = MemoryPhi({entry,3},{Loop.next,5})
; CHECK: MemoryUse(7)
; CHECK-NEXT: %3 = load
  %3 = load i8, i8* %after, align 4, !invariant.group !0

; CHECK: 6 = MemoryDef(7)
; CHECK-NEXT: call void @clobber8
  call void @clobber8(i8* %after)

; CHECK: MemoryUse(7)
; CHECK-NEXT: %4 = load
  %4 = load i8, i8* %after, align 4, !invariant.group !0
  br i1 undef, label %Ret, label %Loop.Body

Ret:
  ret i8 %3
}

define i8 @loop4(i8* %p) {
entry:
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i8
  store i8 4, i8* %p, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: call void @clobber
  call void @clobber8(i8* %p)
; CHECK: 3 = MemoryDef(2)
; CHECK-NEXT: %after = call i8* @llvm.launder.invariant.group.p0i8(i8* %p)
  %after = call i8* @llvm.launder.invariant.group.p0i8(i8* %p)
  br i1 undef, label %Loop.Pre, label %Loop.End

Loop.Pre:
; CHECK: MemoryUse(2)
; CHECK-NEXT: %0 = load i8
  %0 = load i8, i8* %after, !invariant.group !0
  br label %Loop.Body
Loop.Body:
; CHECK: 6 = MemoryPhi({Loop.Pre,3},{Loop.Body,4},{Loop.End,5})
; CHECK-NEXT: MemoryUse(2)
; CHECK-NEXT: %1 = load i8
  %1 = load i8, i8* %after, !invariant.group !0

; CHECK: MemoryUse(1)
; CHECK-NEXT: %2 = load i8
  %2 = load i8, i8* %p, !invariant.group !0

; CHECK: 4 = MemoryDef(6)
  store i8 4, i8* %after, !invariant.group !0
  br i1 undef, label %Loop.End, label %Loop.Body

Loop.End:
; CHECK: 5 = MemoryPhi({entry,3},{Loop.Body,4})
; CHECK-NEXT: MemoryUse(2)
; CHECK-NEXT: %3 = load
  %3 = load i8, i8* %after, align 4, !invariant.group !0

; CHECK: MemoryUse(1)
; CHECK-NEXT: %4 = load
  %4 = load i8, i8* %p, align 4, !invariant.group !0
  br i1 undef, label %Ret, label %Loop.Body

Ret:
  ret i8 %3
}

; In the future we would like to CSE barriers if there is no clobber between.
; CHECK-LABEL: define i8 @optimizable()
define i8 @optimizable() {
entry:
  %ptr = alloca i8
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i8 42, i8* %ptr, !invariant.group !0
  store i8 42, i8* %ptr, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: call i8* @llvm.launder.invariant.group
  %ptr2 = call i8* @llvm.launder.invariant.group.p0i8(i8* %ptr)
; FIXME: This one could be CSEd.
; CHECK: 3 = MemoryDef(2)
; CHECK: call i8* @llvm.launder.invariant.group
  %ptr3 = call i8* @llvm.launder.invariant.group.p0i8(i8* %ptr)
; CHECK: 4 = MemoryDef(3)
; CHECK-NEXT: call void @clobber8(i8* %ptr)
  call void @clobber8(i8* %ptr)
; CHECK: 5 = MemoryDef(4)
; CHECK-NEXT: call void @use(i8* %ptr2)
  call void @use(i8* %ptr2)
; CHECK: 6 = MemoryDef(5)
; CHECK-NEXT: call void @use(i8* %ptr3)
  call void @use(i8* %ptr3)
; CHECK: MemoryUse(6)
; CHECK-NEXT: load i8, i8* %ptr3, {{.*}}!invariant.group
  %v = load i8, i8* %ptr3, !invariant.group !0

  ret i8 %v
}

; CHECK-LABEL: define i8 @unoptimizable2()
define i8 @unoptimizable2() {
  %ptr = alloca i8
; CHECK: 1 = MemoryDef(liveOnEntry)
; CHECK-NEXT: store i8 42, i8* %ptr, !invariant.group !0
  store i8 42, i8* %ptr, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
; CHECK-NEXT: call i8* @llvm.launder.invariant.group
  %ptr2 = call i8* @llvm.launder.invariant.group.p0i8(i8* %ptr)
; CHECK: 3 = MemoryDef(2)
  store i8 43, i8* %ptr
; CHECK: 4 = MemoryDef(3)
; CHECK-NEXT: call i8* @llvm.launder.invariant.group
  %ptr3 = call i8* @llvm.launder.invariant.group.p0i8(i8* %ptr)
; CHECK: 5 = MemoryDef(4)
; CHECK-NEXT: call void @clobber8(i8* %ptr)
  call void @clobber8(i8* %ptr)
; 6 = MemoryDef(5)
; CHECK-NEXT  call void @use(i8* %ptr2)
  call void @use(i8* %ptr2)
; CHECK: 7 = MemoryDef(6)
; CHECK-NEXT: call void @use(i8* %ptr3)
  call void @use(i8* %ptr3)
; CHECK: MemoryUse(7)
; CHECK-NEXT: %v = load i8, i8* %ptr3, !invariant.group !0
  %v = load i8, i8* %ptr3, !invariant.group !0
  ret i8 %v
}

; CHECK-LABEL: define i8 @diamond(
define i8 @diamond(i8* %p) {
entry:
; CHECK: 1 = MemoryDef(liveOnEntry)
  store i8 4, i8* %p, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
  %after = call i8* @llvm.launder.invariant.group.p0i8(i8* %p)
; CHECK: 3 = MemoryDef(2)
  call void @clobber8(i8* %p)
  br i1 undef, label %First, label %Ret

First:                                            ; preds = %entry
; CHECK: MemoryUse(3)
  %0 = load i8, i8* %after, !invariant.group !0
; CHECK: 4 = MemoryDef(3)
  call void @clobber8(i8* %p)
  br i1 undef, label %Second1, label %Second2

Second1:                                          ; preds = %First
; CHECK: 5 = MemoryDef(4)
  call void @clobber8(i8* %p)
; CHECK: MemoryUse(3)
  %1 = load i8, i8* %after, !invariant.group !0
; CHECK: MemoryUse(1)
  %2 = load i8, i8* %p, !invariant.group !0
; CHECK: 6 = MemoryDef(5)
  call void @clobber8(i8* %p)
  br label %Diamond

Second2:                                          ; preds = %First
; CHECK: 7 = MemoryDef(4)
  call void @clobber8(i8* %p)
; CHECK: MemoryUse(3)
  %3 = load i8, i8* %after, !invariant.group !0
; CHECK: MemoryUse(1)
  %4 = load i8, i8* %p, !invariant.group !0

; CHECK: 8 = MemoryDef(7)
  call void @clobber8(i8* %p)
  br label %Diamond

Diamond:                                          ; preds = %Second2, %Second1
; CHECK: 12 = MemoryPhi({Second1,6},{Second2,8})
; CHECK: 9 = MemoryDef(12)
  call void @clobber8(i8* %p)
; CHECK: MemoryUse(1)
  %5 = load i8, i8* %p, !invariant.group !0

; CHECK: 10 = MemoryDef(9)
  call void @clobber8(i8* %p)
  br label %Ret

Ret:                                              ; preds = %Diamond, %entry
; CHECK: 13 = MemoryPhi({entry,3},{Diamond,10})
; CHECK: 11 = MemoryDef(13)
  call void @clobber8(i8* %p)
; CHECK: MemoryUse(3)
  %6 = load i8, i8* %after, !invariant.group !0
; CHECK: MemoryUse(1)
  %7 = load i8, i8* %p, !invariant.group !0
  ret i8 %7
}

; From NewGVN/invariant.group.ll
@unknownPtr = external global i8
; CHECK-LABEL: define void @testGlobal() {
define void @testGlobal() {
; CHECK: MemoryUse(liveOnEntry)
  %a = load i8, i8* @unknownPtr, !invariant.group !0
; CHECK: 1 = MemoryDef(liveOnEntry)
  call void @clobber8(i8* @unknownPtr)
; CHECK: MemoryUse(liveOnEntry)
  %1 = load i8, i8* @unknownPtr, !invariant.group !0
; CHECK: 2 = MemoryDef(1)
  call void @clobber8(i8* @unknownPtr)
  %b0 = bitcast i8* @unknownPtr to i1*
; CHECK: 3 = MemoryDef(2)
  call void @clobber8(i8* @unknownPtr)
; CHECK: MemoryUse(liveOnEntry)
  %2 = load i1, i1* %b0, !invariant.group !0
; CHECK: 4 = MemoryDef(3)
  call void @clobber8(i8* @unknownPtr)
; CHECK: MemoryUse(liveOnEntry)
  %3 = load i1, i1* %b0, !invariant.group !0
  ret void
}


%struct.A = type { i32 (...)** }
@_ZTV1A = available_externally unnamed_addr constant [3 x i8*] [i8* null, i8* bitcast (i8** @_ZTI1A to i8*), i8* bitcast (void (%struct.A*)* @_ZN1A3fooEv to i8*)], align 8
@_ZTI1A = external constant i8*
declare void @_ZN1A3fooEv(%struct.A*)
declare void @_ZN1AC1Ev(%struct.A*)
declare i8* @getPointer(i8*)

; CHECK-LABEL: define void @combiningBitCastWithLoad() {
define void @combiningBitCastWithLoad() {
  %a = alloca %struct.A*, align 8
  %s2 = bitcast %struct.A** %a to i8*
; CHECK: 1 = MemoryDef(liveOnEntry)
  call void @clobber8(i8* null)
  %x = bitcast i8* %s2 to i1*
; CHECK: 2 = MemoryDef(1)
  store i1 1, i1* %x, !invariant.group !0
  %1 = bitcast i8* %s2 to %struct.A*
; CHECK: 3 = MemoryDef(2)
  call void @_ZN1AC1Ev(%struct.A* %1)
  %2 = bitcast %struct.A* %1 to i8***
; CHECK: MemoryUse(2)
  %vtable = load i8**, i8*** %2, align 8, !invariant.group !0
  %cmp.vtables = icmp eq i8** %vtable, getelementptr inbounds ([3 x i8*], [3 x i8*]* @_ZTV1A, i64 0, i64 2)
; CHECK: 4 = MemoryDef(3)
  store %struct.A* %1, %struct.A** %a, align 8
; CHECK: MemoryUse(4)
  %3 = load %struct.A*, %struct.A** %a, align 8
  %4 = bitcast %struct.A* %3 to void (%struct.A*)***
; CHECK: MemoryUse(4)
  %vtable1 = load void (%struct.A*)**, void (%struct.A*)*** %4, align 8, !invariant.group !0
  %vfn = getelementptr inbounds void (%struct.A*)*, void (%struct.A*)** %vtable1, i64 0
; CHECK: MemoryUse(4)
  %5 = load void (%struct.A*)*, void (%struct.A*)** %vfn, align 8
; CHECK: 5 = MemoryDef(4)
  call void %5(%struct.A* %3)
  ret void
}

declare i8* @llvm.launder.invariant.group.p0i8(i8*)
declare void @clobber(i32*)
declare void @clobber8(i8*)
declare void @use(i8* readonly)

!0 = !{}
