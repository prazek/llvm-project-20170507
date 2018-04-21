//===--- AddVirtualCheck.cpp - clang-tidy----------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "AddVirtualCheck.h"
#include "clang/AST/ASTContext.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include <iostream>

using namespace clang::ast_matchers;

namespace clang {
namespace tidy {
namespace misc {

void AddVirtualCheck::registerMatchers(MatchFinder *Finder) {
  Finder->addMatcher(cxxMethodDecl(
      hasAncestor(cxxRecordDecl().bind("class")),
      unless(anyOf(isVirtual(), isImplicit(), cxxConstructorDecl(),
                   isStaticStorageClass(),
                   hasParent(functionTemplateDecl())))).bind("fun"), this);

  Finder->addMatcher(cxxRecordDecl(isDefinition()).bind("class"), this);
}

void AddVirtualCheck::check(const MatchFinder::MatchResult &Result) {
  auto *MethodDecl = Result.Nodes.getNodeAs<CXXMethodDecl>("fun");
  auto *ClassDecl = Result.Nodes.getNodeAs<CXXRecordDecl>("class");
  assert(ClassDecl != nullptr);

  if (ClassDecl->getLocation().isMacroID())
    return;

  if (ClassDecl->isAggregate() || ClassDecl->hasTrivialDefaultConstructor()
      || ClassDecl->isLiteral()) {
    auto loc = (MethodDecl ? (Decl*)MethodDecl : (Decl*)ClassDecl)->getSourceRange().getBegin();
    diag(loc, "Can't add the virtual here.", DiagnosticIDs::Level::Note);
    return;
  }

  if (!MethodDecl) {
   if (ClassDecl->hasUserDeclaredDestructor() or ClassDecl->getName().empty())
      return;
    std::string insertion =
        "public: virtual ~" + ClassDecl->getName().str() + "() = default;\n";
    diag(ClassDecl->getSourceRange().getBegin(),
         "implicit destructor can be slowed down by adding virtual")
        << FixItHint::CreateInsertion(ClassDecl->getSourceRange().getEnd(),
                                      insertion);
   return;
  }

  // TODO static
  if (MethodDecl->isStatic() || MethodDecl->isOutOfLine()
      || MethodDecl->getLocation().isMacroID())
    return;

  diag(MethodDecl->getSourceRange().getBegin(),
       "function can be slowed down by adding virtual")
      << FixItHint::CreateInsertion(MethodDecl->getSourceRange().getBegin(),
                                    "virtual ");
}

} // namespace misc
} // namespace tidy
} // namespace clang
