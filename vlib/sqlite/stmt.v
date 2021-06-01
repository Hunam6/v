module sqlite

fn C.sqlite3_bind_double(&C.sqlite3_stmt, int, f64) int
fn C.sqlite3_bind_int(&C.sqlite3_stmt, int, int) int
fn C.sqlite3_bind_int64(&C.sqlite3_stmt, int, i64) int
fn C.sqlite3_bind_text(&C.sqlite3_stmt, int, &char, int, voidptr) int

// Only for V ORM
fn (db DB) init_stmt(query string) &C.sqlite3_stmt {
	// println('init_stmt("$query")')
	stmt := &C.sqlite3_stmt(0)
	C.sqlite3_prepare_v2(db.conn, &char(query.str), query.len, &stmt, 0)
	return stmt
}

fn (db DB) new_init_stmt(query string) Stmt {
	return Stmt{db.init_stmt(query), unsafe { &db }}
}

fn (stmt Stmt) bind_int(idx int, v int) int {
	return C.sqlite3_bind_int(stmt.stmt, idx, v)
}

fn (stmt Stmt) bind_i64(idx int, v i64) int {
	return C.sqlite3_bind_int64(stmt.stmt, idx, v)
}

fn (stmt Stmt) bind_f64(idx int, v f64) int {
	return C.sqlite3_bind_double(stmt.stmt, idx, v)
}

fn (stmt Stmt) bind_text(idx int, s string) int {
	return C.sqlite3_bind_text(stmt.stmt, idx, s.str, s.len, 0)
}

fn (stmt Stmt) step() int {
	return C.sqlite3_step(stmt.stmt)
}

fn (stmt Stmt) orm_step() ? {
	res := stmt.step()
	if res != sqlite_ok && res != sqlite_done {
		return stmt.db.error_message(res)
	}
}

fn (stmt Stmt) finalize() {
	C.sqlite3_finalize(stmt.stmt)
}