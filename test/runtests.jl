using PrintTypeTree
using Test
using SparseArrays

@testset "Integer" begin
    io = IOBuffer()
    typetree(io, Integer)
    s = String(take!(io))

    ref = "\e[0mAny (other children are hidden)\n└─ \e[0mNumber\n   ├─ \e[0mBase.MultiplicativeInverses.MultiplicativeInverse (2 children)\n   ├─ \e[0mComplex\n   └─ \e[0mReal\n      ├─ \e[0mAbstractFloat (5 children)\n      ├─ \e[0mAbstractIrrational (1 children)\n      ├─ \e[31mInteger\e[39m\n      │  ├─ \e[0mBool\n      │  ├─ \e[0mSigned\n      │  │  ├─ \e[0mBigInt\n      │  │  ├─ \e[0mInt128\n      │  │  ├─ \e[0mInt16\n      │  │  ├─ \e[0mInt32\n      │  │  ├─ \e[0mInt64\n      │  │  └─ \e[0mInt8\n      │  └─ \e[0mUnsigned\n      │     ├─ \e[0mUInt128\n      │     ├─ \e[0mUInt16\n      │     ├─ \e[0mUInt32\n      │     ├─ \e[0mUInt64\n      │     └─ \e[0mUInt8\n      └─ \e[0mRational\n"
    @test s == ref
end

@testset "type alias" begin
    io = IOBuffer()
    # There is an intermediate type alias in the type tree of `SparseMatrixCSC`,
    # which is `AbstractSparseMatrix = AbstractSparseArray{Tv, Ti, 2}`.
    # See `subtypes(supertype(supertype(SparseArrays.AbstractSparseMatrixCSC)))` for details.
    # The type alias in the middle of the type tree should be handled correctly.
    typetree(io, SparseMatrixCSC)
    s = String(take!(io))

    ref = "\e[0mAny (other children are hidden)\n└─ \e[0mAbstractMatrix\n   ├─ \e[0mAbstractSlices{T, 2} where T (1 children)\n   ├─ \e[0mAbstractSparseMatrix{Tv, Ti} where {Tv, Ti<:Integer}\n   │  ├─ \e[0mSparseArrays.AbstractSparseMatrixCSC\n   │  │  ├─ \e[0mSparseArrays.FixedSparseCSC\n   │  │  └─ \e[31mSparseMatrixCSC\e[39m\n   │  └─ \e[0mSparseArrays.CHOLMOD.Sparse\n   ├─ \e[0mBase.ReinterpretArray{T, 2, S} where {T, S}\n   ├─ \e[0mBase.ReshapedArray{T, 2} where T\n   ├─ \e[0mBase.SCartesianIndices2\n   ├─ \e[0mBitMatrix\n   ├─ \e[0mCartesianIndices{2, R} where R<:Tuple{OrdinalRange{Int64, Int64}, OrdinalRange{Int64, Int64}}\n   ├─ \e[0mDenseMatrix (3 children)\n   ├─ \e[0mGenericArray{T, 2} where T\n   ├─ \e[0mLinearAlgebra.AbstractTriangular (4 children)\n   ├─ \e[0mLinearAlgebra.Adjoint\n   ├─ \e[0mLinearAlgebra.Bidiagonal\n   ├─ \e[0mLinearAlgebra.Diagonal\n   ├─ \e[0mLinearAlgebra.Hermitian\n   ├─ \e[0mLinearAlgebra.SymTridiagonal\n   ├─ \e[0mLinearAlgebra.Symmetric\n   ├─ \e[0mLinearAlgebra.Transpose\n   ├─ \e[0mLinearAlgebra.Tridiagonal\n   ├─ \e[0mLinearAlgebra.UpperHessenberg\n   ├─ \e[0mLinearIndices{2, R} where R<:Tuple{AbstractUnitRange{Int64}, AbstractUnitRange{Int64}}\n   ├─ \e[0mPermutedDimsArray{T, 2} where T\n   ├─ \e[0mSparseArrays.CHOLMOD.FactorComponent\n   ├─ \e[0mSparseArrays.ReadOnly{Tv, 2, V} where {Tv, V<:AbstractMatrix{Tv}}\n   └─ \e[0mSubArray{T, 2} where T\n"
    @test s == ref
end
