module PrintTypeTree

using InteractiveUtils: subtypes
using AbstractTrees

export typetree

mutable struct TypeTreeNode
    value::Type
    children::Vector{TypeTreeNode}
    color::Symbol
    annotation::Union{String,Nothing}
end

TypeTreeNode(value, children, color) = TypeTreeNode(value, children, color, nothing)
TypeTreeNode(value, children) = TypeTreeNode(value, children, :normal)

AbstractTrees.nodevalue(n::TypeTreeNode) = n.value

AbstractTrees.children(n::TypeTreeNode) = n.children

function AbstractTrees.printnode(io::IO, n::TypeTreeNode; kw...)
    s = nodevalue(n)
    if !isnothing(n.annotation)
        s = "$(s) $(n.annotation)"
    end
    printstyled(IOContext(io, :color => true), s; color=n.color)
end

function get_subtypes_nodes(T::Type; onelevel=false)
    subs = subtypes(T)
    nodes = TypeTreeNode[]
    for i in subs
        subnodes = onelevel ? TypeTreeNode[] : get_subtypes_nodes(i)
        t = TypeTreeNode(i, subnodes)
        if onelevel
            n = length(subtypes(i))
            # if 0 children, no need to add annotation
            (n > 0) && (t.annotation = "($n children)")
        end
        push!(nodes, t)
    end
    return nodes
end

"""
    typetree(io=stdout, T)

Print type hierarchy tree.

For a type `T`, print
- all the subtypes of `T`, recursively
- the supertypes of `T` until `Any`
- except the branch of `T`, the type tree of the children of the supertypes are
    folded, but annotated with a visual cue of `(n children)` for those
    having n > 0 children
- the children of `Any` are hidden, and annotated with `(other children are hidden)`,
    to avoid printing too many types
- the type `T` is highlighted in red

# Examples
```julia
julia> using PrintTypeTree
julia> typetree(Integer)
julia> # Note that the `Integer` will be highlighted in red
Any (other children are hidden)
└─ Number
   ├─ Base.MultiplicativeInverses.MultiplicativeInverse (2 children)
   ├─ Complex
   └─ Real
      ├─ AbstractFloat (5 children)
      ├─ AbstractIrrational (1 children)
      ├─ Integer
      │  ├─ Bool
      │  ├─ Signed
      │  │  ├─ BigInt
      │  │  ├─ Int128
      │  │  ├─ Int16
      │  │  ├─ Int32
      │  │  ├─ Int64
      │  │  └─ Int8
      │  └─ Unsigned
      │     ├─ UInt128
      │     ├─ UInt16
      │     ├─ UInt32
      │     ├─ UInt64
      │     └─ UInt8
      └─ Rational
"""
function typetree(io::IO, T::Type)
    # subtypes tree
    tree = TypeTreeNode(T, get_subtypes_nodes(T), :red)

    # supertype tree
    while true
        sup = supertype(tree.value)
        if sup === Any
            # Do not show the subtypes of Any, because it is too long
            tree = TypeTreeNode(Any, [tree])
            tree.annotation = "(other children are hidden)"
            break
        end
        # only show one level of subtypes of parent
        sub = get_subtypes_nodes(sup; onelevel=true)
        i = findfirst(x -> x.value == tree.value, sub)
        sub[i] = tree
        tree = TypeTreeNode(sup, sub)
    end

    print_tree(io, tree)
end

typetree(T::Type) = typetree(stdout, T)

end
