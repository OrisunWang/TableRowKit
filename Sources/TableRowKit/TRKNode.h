#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// An ordered tree node used by the table data source and sections. Mutate on the main thread.
@interface TRKNode : NSObject <NSFastEnumeration>

/// The current owner; insertion and removal update this weak reference.
@property (nonatomic, weak, readonly, nullable) __kindof TRKNode *parent;
/// An ordered snapshot; assignment replaces children through the normal lifecycle.
@property (nonatomic, copy, nullable) NSArray<__kindof TRKNode *> *children;

/// Appends a node, moving it from its old parent when needed.
- (void)addChild:(TRKNode *)node;
/// Appends nodes in array order.
- (void)addChildrenFromArray:(NSArray<TRKNode *> *)array;
/// Inserts at the final index; invalid indices and cycles are ignored.
- (void)insertChild:(TRKNode *)node atIndex:(NSUInteger)index;
/// Inserts nodes in array order at a valid index.
- (void)insertChildFromArray:(NSArray<TRKNode *> *)array atIndex:(NSUInteger)index;
/// Inserts immediately before a direct sibling.
- (void)insertChild:(TRKNode *)node beforeNode:(TRKNode *)siblingNode;
/// Inserts immediately after a direct sibling.
- (void)insertChild:(TRKNode *)node afterNode:(TRKNode *)siblingNode;
/// Inserts nodes immediately before a direct sibling.
- (void)insertChildFromArray:(NSArray<TRKNode *> *)array beforeNode:(TRKNode *)siblingNode;
/// Inserts nodes immediately after a direct sibling.
- (void)insertChildFromArray:(NSArray<TRKNode *> *)array afterNode:(TRKNode *)siblingNode;
/// Removes a direct child.
- (void)removeChild:(TRKNode *)node;
/// Removes this node from its parent.
- (void)removeFromParent;
/// Removes every child through removeChild: so subclass callbacks run.
- (void)removeAllChildren;
/// The index in the parent, or NSNotFound for a detached node.
- (NSUInteger)nodeIndex;
/// The first direct child, if any.
- (nullable __kindof TRKNode *)firstChild;
/// The last direct child, if any.
- (nullable __kindof TRKNode *)lastChild;
/// Other children of the same parent in current order.
- (NSArray<__kindof TRKNode *> *)siblings;
/// Whether this node is the first child of a parent.
- (BOOL)isFirstChild;
/// Whether this node is the last child of a parent.
- (BOOL)isLastChild;
/// The next sibling, if any.
- (nullable __kindof TRKNode *)nextSibling;
/// The previous sibling, if any.
- (nullable __kindof TRKNode *)previousSibling;
/// Number of direct children.
- (NSUInteger)count;
/// Direct child at idx; invalid indices raise like NSArray subscripting.
- (__kindof TRKNode *)objectAtIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
