/**
 * @file    Compiler.h
 * @brief   AUTOSAR Compiler Abstraction (AUTOSAR SWS_CompilerAbstraction)
 */
#ifndef COMPILER_H
#define COMPILER_H

#define AUTOMATIC          /* automatic storage class            */
#define STATIC   static    /* static storage class               */
#define INLINE   inline    /* inline hint                        */

#define FUNC(rettype, memclass)           rettype
#define FUNC_P2CONST(rettype, ptrclass, memclass)  const rettype *
#define P2CONST(ptrtype, memclass, ptrclass)       const ptrtype *
#define P2VAR(ptrtype, memclass, ptrclass)         ptrtype *
#define CONST(consttype, memclass)                 const consttype
#define VAR(vartype, memclass)                     vartype

#endif /* COMPILER_H */
