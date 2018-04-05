; REQUIRES: asserts
; RUN: opt < %s -licm -disable-basicaa -stats -S 2>&1 | grep "2 licm"
; RUN: opt < %s -licm -disable-basicaa -S | FileCheck %s

@"\01L_OBJC_METH_VAR_NAME_" = internal global [4 x i8] c"foo\00", section "__TEXT,__objc_methname,cstring_literals", align 1
@"\01L_OBJC_SELECTOR_REFERENCES_" = internal global i8* getelementptr inbounds ([4 x i8], [4 x i8]* @"\01L_OBJC_METH_VAR_NAME_", i32 0, i32 0), section "__DATA, __objc_selrefs, literal_pointers, no_dead_strip"
@"\01L_OBJC_IMAGE_INFO" = internal constant [2 x i32] [i32 0, i32 16], section "__DATA, __objc_imageinfo, regular, no_dead_strip"
@llvm.used = appending global [3 x i8*] [i8* getelementptr inbounds ([4 x i8], [4 x i8]* @"\01L_OBJC_METH_VAR_NAME_", i32 0, i32 0), i8* bitcast (i8** @"\01L_OBJC_SELECTOR_REFERENCES_" to i8*), i8* bitcast ([2 x i32]* @"\01L_OBJC_IMAGE_INFO" to i8*)], section "llvm.metadata"
; CHECK-LABEL: define void @test(
define void @test(i8* %x) uwtable ssp {
entry:
  %x.addr = alloca i8*, align 8
  %i = alloca i32, align 4
  store i8* %x, i8** %x.addr, align 8
  store i32 0, i32* %i, align 4
; CHECK: load i8*, i8** @"\01L_OBJC_SELECTOR_REFERENCES_"{{$}}
  br label %for.cond
; CHECK: for.cond:
for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, i32* %i, align 4
  %cmp = icmp ult i32 %0, 10000
  br i1 %cmp, label %for.body, label %for.end
for.body:                                         ; preds = %for.cond
  %1 = load i8*, i8** %x.addr, align 8
  %2 = load i8*, i8** @"\01L_OBJC_SELECTOR_REFERENCES_", !invariant.load !0
  %call = call i8* bitcast (i8* (i8*, i8*, ...)* @objc_msgSend to i8* (i8*, i8*)*)(i8* %1, i8* %2)
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %3 = load i32, i32* %i, align 4
  %inc = add i32 %3, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  ret void
}

; This test checks if we keep !invariant.load metadata on the instruction after
; hoisting.
; CHECK-LABEL: @keep_metadata(
define void @keep_metadata(i8** dereferenceable(8) %arg) {
entry:

  br i1 undef, label %while.end, label %while.body.lr.ph
; CHECK: while.body.lr.ph:
while.body.lr.ph:                                 ; preds = %entry
; CHECK: load i8*, i8** %{{...}}, align 8, !invariant.load
  br label %while.body
; CHECK:       while.body:
while.body:                                       ; preds = %while.body, %while.body.lr.ph

  %x = load i8*, i8** %arg, align 8, !invariant.load !0
  call void @foo(i8* %x)

  br i1 undef, label %while.end.loopexit, label %while.body

while.end.loopexit:                               ; preds = %while.body
  br label %while.end

while.end:                                        ; preds = %while.end.loopexit, %entry
  ret void
}

declare i8* @objc_msgSend(i8*, i8*, ...) nonlazybind
declare void @foo(i8*)

!0 = !{}
