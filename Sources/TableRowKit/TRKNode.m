#import "TRKNode.h"

@interface TRKNode () {
    /// Owns children in display order; UIKit clients mutate on the main thread.
    NSMutableArray<TRKNode *> *_mutableChildren;
    /// Changes on every edit so fast enumeration detects concurrent mutation.
    unsigned long _mutationCount;
}
/// Tracks ownership without retaining the parent; tree methods alone update it.
@property (nonatomic, weak, readwrite, nullable) TRKNode *parent;
@end

@implementation TRKNode

/// Returns a snapshot so callers cannot edit internal storage.
- (NSArray<TRKNode *> *)children { return [_mutableChildren copy] ?: @[]; }

/// Routes replacement through virtual methods to preserve subclass callbacks.
- (void)setChildren:(NSArray<TRKNode *> *)children {
    NSArray<TRKNode *> *snapshot = [children copy];
    [self removeAllChildren];
    [self addChildrenFromArray:snapshot ?: @[]];
}

/// Appends at the current count.
- (void)addChild:(TRKNode *)node { [self insertChild:node atIndex:self.count]; }

/// Applies the same validation as a single insertion.
- (void)addChildrenFromArray:(NSArray<TRKNode *> *)array {
    for (TRKNode *node in [array copy]) { [self addChild:node]; }
}

/// Prevents cycles, detaches an existing owner, then inserts at the final index.
- (void)insertChild:(TRKNode *)node atIndex:(NSUInteger)index {
    if (![node isKindOfClass:[TRKNode class]] || index > self.count) { return; }
    for (TRKNode *ancestor = self; ancestor != nil; ancestor = ancestor.parent) {
        if (ancestor == node) { return; }
    }
    [node removeFromParent];
    if (_mutableChildren == nil) { _mutableChildren = [NSMutableArray array]; }
    [_mutableChildren insertObject:node atIndex:MIN(index, _mutableChildren.count)];
    node.parent = self;
    _mutationCount++;
}

/// Uses a snapshot because insertion may remove nodes from the source parent.
- (void)insertChildFromArray:(NSArray<TRKNode *> *)array atIndex:(NSUInteger)index {
    if (index > self.count) { return; }
    for (TRKNode *node in [array copy]) {
        [self insertChild:node atIndex:MIN(index, self.count)];
        if (node.parent == self) { index = MIN(index + 1, self.count); }
    }
}

/// Unknown siblings cause no change.
- (void)insertChild:(TRKNode *)node beforeNode:(TRKNode *)siblingNode {
    NSUInteger index = [self.children indexOfObjectIdenticalTo:siblingNode];
    if (index != NSNotFound) { [self insertChild:node atIndex:index]; }
}

/// Unknown siblings cause no change.
- (void)insertChild:(TRKNode *)node afterNode:(TRKNode *)siblingNode {
    NSUInteger index = [self.children indexOfObjectIdenticalTo:siblingNode];
    if (index != NSNotFound) { [self insertChild:node atIndex:index + 1]; }
}

/// Inserts an ordered group before a direct sibling.
- (void)insertChildFromArray:(NSArray<TRKNode *> *)array beforeNode:(TRKNode *)siblingNode {
    NSUInteger index = [self.children indexOfObjectIdenticalTo:siblingNode];
    if (index != NSNotFound) { [self insertChildFromArray:array atIndex:index]; }
}

/// Inserts an ordered group after a direct sibling.
- (void)insertChildFromArray:(NSArray<TRKNode *> *)array afterNode:(TRKNode *)siblingNode {
    NSUInteger index = [self.children indexOfObjectIdenticalTo:siblingNode];
    if (index != NSNotFound) { [self insertChildFromArray:array atIndex:index + 1]; }
}

/// Clears ownership only for a node actually contained by this parent.
- (void)removeChild:(TRKNode *)node {
    NSUInteger index = [self.children indexOfObjectIdenticalTo:node];
    if (index == NSNotFound) { return; }
    [_mutableChildren removeObjectAtIndex:index];
    node.parent = nil;
    _mutationCount++;
}

/// Uses the parent's virtual method so section lifecycle callbacks are preserved.
- (void)removeFromParent { [self.parent removeChild:self]; }

/// Uses a snapshot because callbacks may change storage.
- (void)removeAllChildren {
    for (TRKNode *node in self.children) { [self removeChild:node]; }
}

/// Uses identity and reports detached nodes correctly.
- (NSUInteger)nodeIndex {
    return self.parent == nil ? NSNotFound : [self.parent.children indexOfObjectIdenticalTo:self];
}

/// Returns the first child.
- (TRKNode *)firstChild { return _mutableChildren.firstObject; }
/// Returns the last child.
- (TRKNode *)lastChild { return _mutableChildren.lastObject; }

/// Excludes this node from a parent snapshot.
- (NSArray<TRKNode *> *)siblings {
    if (self.parent == nil) { return @[]; }
    NSMutableArray<TRKNode *> *result = [self.parent.children mutableCopy];
    [result removeObjectIdenticalTo:self];
    return result;
}

/// Detached nodes cannot be first.
- (BOOL)isFirstChild { return self.parent != nil && self.parent.firstChild == self; }
/// Detached nodes cannot be last.
- (BOOL)isLastChild { return self.parent != nil && self.parent.lastChild == self; }

/// Returns the next direct sibling when its index is valid.
- (TRKNode *)nextSibling {
    NSUInteger index = self.nodeIndex;
    return index != NSNotFound && index + 1 < self.parent.count ? self.parent[index + 1] : nil;
}

/// Avoids unsigned underflow at the first sibling.
- (TRKNode *)previousSibling {
    NSUInteger index = self.nodeIndex;
    return index != NSNotFound && index > 0 ? self.parent[index - 1] : nil;
}

/// Counts direct children.
- (NSUInteger)count { return _mutableChildren.count; }
/// Follows NSArray bounds behavior.
- (TRKNode *)objectAtIndexedSubscript:(NSUInteger)idx { return _mutableChildren[idx]; }

/// Copies each batch into the caller buffer and detects mutation during enumeration.
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    if (state->state >= _mutableChildren.count || len == 0) { return 0; }
    state->mutationsPtr = &_mutationCount;
    state->itemsPtr = buffer;
    NSUInteger batchCount = MIN(len, _mutableChildren.count - state->state);
    for (NSUInteger index = 0; index < batchCount; index++) {
        buffer[index] = _mutableChildren[state->state + index];
    }
    state->state += batchCount;
    return batchCount;
}

@end
