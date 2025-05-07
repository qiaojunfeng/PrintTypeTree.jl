using PrintTypeTree
using Test

@testset "PrintTypeTree.jl" begin
    io = IOBuffer()
    typetree(io, Integer)
    s = String(take!(io))

    ref = "\e[0mAny (other children are hidden)\n└─ \e[0mNumber\n   ├─ \e[0mBase.MultiplicativeInverses.MultiplicativeInverse (2 children)\n   ├─ \e[0mComplex\n   └─ \e[0mReal\n      ├─ \e[0mAbstractFloat (5 children)\n      ├─ \e[0mAbstractIrrational (1 children)\n      ├─ \e[31mInteger\e[39m\n      │  ├─ \e[0mBool\n      │  ├─ \e[0mSigned\n      │  │  ├─ \e[0mBigInt\n      │  │  ├─ \e[0mInt128\n      │  │  ├─ \e[0mInt16\n      │  │  ├─ \e[0mInt32\n      │  │  ├─ \e[0mInt64\n      │  │  └─ \e[0mInt8\n      │  └─ \e[0mUnsigned\n      │     ├─ \e[0mUInt128\n      │     ├─ \e[0mUInt16\n      │     ├─ \e[0mUInt32\n      │     ├─ \e[0mUInt64\n      │     └─ \e[0mUInt8\n      └─ \e[0mRational\n"
    @test s == ref
end
