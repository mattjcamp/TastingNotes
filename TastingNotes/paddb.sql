SQLite format 3   @                                                                             �    ����                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   � �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     1.1UNINITTN                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ) )��                                                                                                                                                                                                                                                                                           ��{tableMetaTableMetaTableCREATE TABLE MetaTable (
 pk INTEGER NOT NULL PRIMARY KEY,
 DatabaseVersion TEXT,
 DatabaseStatus TEXT,
 AppType TEXT
)�5!!�5tableListsTableListsTableCREATE TABLE ListsTable (
 pk INTEGER NOT NULL PRIMARY KEY,
 ListName TEXT,
 ListOrder NUMERIC,
 NoteImageBadgeControl_fk,
 NoteBadge1Control_fk,
 NoteBadge2Control_fk,
 NoteBadge3Control_fk,
 NoteBadge4Control_fk,
 NoteBadge5Control_fk,
 NotesSortedAlpha,
 IsPopulated TEXT
)�%%�ItableSectionTableSectionTableCREATE TABLE SectionTable (
 pk INTEGER NOT NULL PRIMARY KEY,
 fk_ToListsTable INTEGER NOT NULL CONSTRAINT ControlToSection REFERENCES 
  a(pk) ON DELETE CASCADE,
 SectionName TEXT,
 CanDelete TEXT,
 SectionOrder NUMERIC
)      ��     �%%�EtableControlTableControlTableCREATE TABLE ControlTable (
 pk INTEGER NOT NULL PRIMARY KEY,
 fk_ToSectionTable INTEGER NOT NULL CONSTRAINT ControlToSection REFERENCES 
  a(pk) ON DELETE CASCADE,
 ControlType TEXT,
 ControlTitle TEXT,
 ControlPushesToScreen TEXT,
 AllowsMultipleSelections TEXT,
 CanEdit TEXT,
 ControlDescription TEXT,
 ControlOrder NUMERIC,
 IsPopulated TEXT
)�h--�tableNotesInListTableNotesInListTableCREATE TABLE NotesInListTable (
 pk INTEGER NOT NULL PRIMARY KEY,
 fk_ToListsTable INTEGER NOT NULL CONSTRAINT NoteInListToList REFERENCES 
  a(pk) ON DELETE CASCADE,
 NoteOrder NUMERIC
)�{;;�tableContentInNoteAndControlContentInNoteAndControl	CREATE TABLE ContentInNoteAndControl (
 pk INTEGER NOT NULL PRIMARY KEY,
 fk_ToNotesInListTable INTEGER NOT NULL CONSTRAINT ContentToMain REFERENCES a(pk)
  ON DELETE CASCADE,
 fk_ToControlTable INTEGER CONSTRAINT ContentToControl REFERENCES 
  a(pk) ON DELETE CASCADE,
 ContentTextValue TEXT,
 ContentNumValue NUMERIC
)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              (  ( ��](                      �8�?tableTagValuesTagValues
CREATE TABLE TagValues (
 pk INTEGER NOT NULL PRIMARY KEY,
 fk_ToControlTable INTEGER,
 TagValueOrder NUMERIC,
 TagValueText TEXT,
 TagValueNum NUMERIC
)�.11�tableTagValuesInContentTagValuesInContentCREATE TABLE TagValuesInContent (
 pk INTEGER PRIMARY KEY,
 fk_To_TagValues INTEGER,
 fk_To_ContentInNoteAndControl INTEGER
)�F	7!�=triggerDELETE_NotesFromListsListsTable CREATE TRIGGER DELETE_NotesFromLists
BEFORE DELETE ON ListsTable
FOR EACH ROW BEGIN
    DELETE from NotesInListTable WHERE fk_ToListsTable = OLD.pk;
END�H
=!�;triggerDELETE_SectionsFromListsListsTable CREATE TRIGGER DELETE_SectionsFromLists
BEFORE DELETE ON ListsTable
FOR EACH ROW BEGIN
    DELETE from SectionTable WHERE fk_ToListsTable = OLD.pk;
END�UC%�KtriggerDELETE_ControlsFromSectionsSectionTable CREATE TRIGGER DELETE_ControlsFromSections
BEFORE DELETE ON SectionTable
FOR EACH ROW BEGIN 
    DELETE from ControlTable WHERE fk_ToSectionTable = OLD.pk;
END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 g gF+                                                                                                                                                                                                                                                                                                                                                         �\?%�]triggerDELETE_ContentFromControlControlTable CREATE TRIGGER DELETE_ContentFromControl
BEFORE DELETE ON ControlTable
FOR EACH ROW BEGIN 
    DELETE from ContentinNoteAndControl WHERE fk_ToControlTable = OLD.pk;
END�b9-�gtriggerDELETE_ContentFromNoteNotesInListTable CREATE TRIGGER DELETE_ContentFromNote
BEFORE DELETE ON NotesInListTable
FOR EACH ROW BEGIN 
    DELETE from ContentinNoteAndControl WHERE fk_ToNotesInListTable = OLD.pk;
END�RC%�EtriggerDELETE_TagValuesFromControlControlTable CREATE TRIGGER DELETE_TagValuesFromControl
BEFORE DELETE ON ControlTable
FOR EACH ROW BEGIN 
    DELETE from TagValues WHERE fk_ToControlTable = OLD.pk;
END    �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  �cS�]triggerDELETE_TagValuesInNoteFromTagValuesTagValues CREATE TRIGGER DELETE_TagValuesInNoteFromTagValues
BEFORE DELETE ON TagValues
FOR EACH ROW BEGIN 
    DELETE from TagValuesInContent WHERE fk_To_TagValues = OLD.pk;
END�	O;�triggerDELETE_TagValuesInNoteFromContentContentInNoteAndControl CREATE TRIGGER DELETE_TagValuesInNoteFromContent
BEFORE DELETE ON ContentInNoteAndControl
FOR EACH ROW BEGIN 
    DELETE from TagValuesInContent WHERE fk_To_ContentInNoteAndControl = OLD.pk;
END