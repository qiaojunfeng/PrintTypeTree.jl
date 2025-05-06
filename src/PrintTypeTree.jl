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
Print type hierarchy tree.

# Examples
```julia
julia> using PrintTypeTree
julia> typetree(Number)
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
function typetree(T::Type)
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

    print_tree(tree)
end

end
