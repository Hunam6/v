import orm
import sqlite

fn test_orm_stmt_gen_update() {
	query := orm.orm_stmt_gen('Test', "'", .update, true, '?', orm.OrmQueryData{
		fields: ['test', 'a']
		data: []
		types: []
		kinds: []
	}, orm.OrmQueryData{
		fields: ['id', 'name']
		data: []
		types: []
		kinds: [.ge, .eq]
	})
	assert query == "UPDATE 'Test' SET 'test' = ?0, 'a' = ?1 WHERE 'id' >= ?2 AND 'name' == ?3;"
}

fn test_orm_stmt_gen_insert() {
	query := orm.orm_stmt_gen('Test', "'", .insert, true, '?', orm.OrmQueryData{
		fields: ['test', 'a']
		data: []
		types: []
		kinds: []
	}, orm.OrmQueryData{})
	assert query == "INSERT INTO 'Test' ('test', 'a') VALUES (?0, ?1);"
}

fn test_orm_stmt_gen_delete() {
	query := orm.orm_stmt_gen('Test', "'", .delete, true, '?', orm.OrmQueryData{
		fields: ['test', 'a']
		data: []
		types: []
		kinds: []
	}, orm.OrmQueryData{
		fields: ['id', 'name']
		data: []
		types: []
		kinds: [.ge, .eq]
	})
	assert query == "DELETE FROM 'Test' WHERE 'id' >= ?0 AND 'name' == ?1;"
}

fn get_select_fields() []string {
	return ['id', 'test', 'abc']
}

fn test_orm_select_gen() {
	query := orm.orm_select_gen(orm.OrmSelectConfig{
		table: 'test_table'
		fields: get_select_fields()
	}, "'", true, '?', orm.OrmQueryData{})

	assert query == "SELECT 'id', 'test', 'abc' FROM 'test_table' ORDER BY 'id';"
}

fn test_orm_select_gen_with_limit() {
	query := orm.orm_select_gen(orm.OrmSelectConfig{
		table: 'test_table'
		fields: get_select_fields()
		has_limit: true
	}, "'", true, '?', orm.OrmQueryData{})

	assert query == "SELECT 'id', 'test', 'abc' FROM 'test_table' ORDER BY 'id' LIMIT ?0;"
}

fn test_orm_select_gen_with_where() {
	query := orm.orm_select_gen(orm.OrmSelectConfig{
		table: 'test_table'
		fields: get_select_fields()
		has_where: true
	}, "'", true, '?', orm.OrmQueryData{
		fields: ['abc', 'test']
		kinds: [.eq, .gt]
	})

	assert query == "SELECT 'id', 'test', 'abc' FROM 'test_table' WHERE 'abc' == ?0 AND 'test' > ?1 ORDER BY 'id';"
}

fn test_orm_select_gen_with_order() {
	query := orm.orm_select_gen(orm.OrmSelectConfig{
		table: 'test_table'
		fields: get_select_fields()
		has_order: true
		order_type: .desc
	}, "'", true, '?', orm.OrmQueryData{})

	assert query == "SELECT 'id', 'test', 'abc' FROM 'test_table' ORDER BY DESC;"
}

fn test_orm_select_gen_with_offset() {
	query := orm.orm_select_gen(orm.OrmSelectConfig{
		table: 'test_table'
		fields: get_select_fields()
		has_offset: true
	}, "'", true, '?', orm.OrmQueryData{})

	assert query == "SELECT 'id', 'test', 'abc' FROM 'test_table' ORDER BY 'id' OFFSET ?0;"
}

fn test_orm_select_gen_with_all() {
	query := orm.orm_select_gen(orm.OrmSelectConfig{
		table: 'test_table'
		fields: get_select_fields()
		has_limit: true
		has_order: true
		order_type: .desc
		has_offset: true
		has_where: true
	}, "'", true, '?', orm.OrmQueryData{
		fields: ['abc', 'test']
		kinds: [.eq, .gt]
	})

	assert query == "SELECT 'id', 'test', 'abc' FROM 'test_table' WHERE 'abc' == ?0 AND 'test' > ?1 ORDER BY DESC LIMIT ?2 OFFSET ?3;"
}

fn test_orm_table_gen() {
	query := orm.orm_table_gen('test_table', "'", true, 0, [
		orm.OrmTableField{
			name: 'id'
			typ: 7
			kind: .primitive
			default_val: '10'
			attrs: [
				StructAttribute{
					name: 'primary'
				},
				StructAttribute{
					name: 'sql'
					has_arg: true
					arg: 'serial'
					kind: .plain
				},
			]
		},
		orm.OrmTableField{
			name: 'test'
			typ: 18
			kind: .primitive
		},
		orm.OrmTableField{
			name: 'abc'
			typ: 8
			default_val: '6754'
			kind: .primitive
		},
	], sql_type_from_v) or { panic(err) }
	assert query == "CREATE TABLE IF NOT EXISTS 'test_table' ('id' SERIAL DEFAULT 10, 'test' TEXT DEFAULT , 'abc' INT64 DEFAULT 6754, PRIMARY KEY('id'));"
}

fn sql_type_from_v(typ int) ?string {
	return if typ in orm.nums {
		'INT'
	} else if typ in orm.num64 {
		'INT64'
	} else if typ in orm.float {
		'DOUBLE'
	} else if typ == orm.string {
		'TEXT'
	} else if typ == -1 {
		'SERIAL'
	} else {
		error('Unknown type $typ')
	}
}