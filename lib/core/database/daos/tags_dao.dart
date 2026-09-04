import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tags_table.dart';
import '../tables/tasktags_table.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: [Tags, TaskTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  // 1. Tag Queries
  Stream<List<Tag>> watchAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  Future<List<Tag>> getAllTags() {
    return (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
  }

  Future<Tag?> getTagById(int id) {
    return (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // 2. Tag CRUD
  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<bool> updateTag(Tag tag) => update(tags).replace(tag);

  Future<int> deleteTag(int id) {
    return (delete(tags)..where((t) => t.id.equals(id))).go();
  }

  // 3. Task <-> Tag Relations
  Stream<List<Tag>> watchTagsForTask(int taskId) {
    final query = select(tags).join([
      innerJoin(taskTags, taskTags.tagId.equalsExp(tags.id)),
    ])..where(taskTags.taskId.equals(taskId));

    return query.map((row) => row.readTable(tags)).watch();
  }

  Future<List<Tag>> getTagsForTask(int taskId) {
    final query = select(tags).join([
      innerJoin(taskTags, taskTags.tagId.equalsExp(tags.id)),
    ])..where(taskTags.taskId.equals(taskId));

    return query.map((row) => row.readTable(tags)).get();
  }

  Future<int> addTagToTask(int taskId, int tagId) {
    return into(taskTags).insertOnConflictUpdate(
      TaskTagsCompanion.insert(taskId: taskId, tagId: tagId),
    );
  }

  Future<int> removeTagFromTask(int taskId, int tagId) {
    return (delete(taskTags)
          ..where((tt) => tt.taskId.equals(taskId) & tt.tagId.equals(tagId)))
        .go();
  }

  Future<void> setTagsForTask(int taskId, List<int> tagIds) {
    return transaction(() async {
      await (delete(taskTags)..where((tt) => tt.taskId.equals(taskId))).go();
      for (final tagId in tagIds) {
        await into(taskTags).insert(
          TaskTagsCompanion.insert(taskId: taskId, tagId: tagId),
        );
      }
    });
  }
}
