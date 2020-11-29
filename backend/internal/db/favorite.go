package db

import (
	"context"

	sq "github.com/Masterminds/squirrel"
	log "github.com/sirupsen/logrus"
)

func (d *Database) AddFavorites(username, filename string) error {
	conn, err := d.pool.Acquire(context.Background())
	if err != nil {
		log.Printf("Unable to acquire a database connection: %v\n", err)
		return err
	}
	defer conn.Release()

	q := sq.Insert(favoriteTable).Columns("login, filename").Values("", "")
	query, _, err := q.ToSql()
	if err != nil {
		log.Println("Can`t convert to sql")
		return err
	}

	if _, err = conn.Exec(context.Background(), query, username, filename); err != nil {
		log.Printf("Can`t exec query: %s\n", query)
		return err
	}

	return nil
}

func (d *Database) DeleteFavorites(username, filename string) error {
	conn, err := d.pool.Acquire(context.Background())
	if err != nil {
		log.Printf("Unable to acquire a database connection: %v\n", err)
		return err
	}
	defer conn.Release()

	q := sq.Delete(favoriteTable).Where(sq.Eq{"login": username, "filename": filename})
	query, _, err := q.ToSql()
	if err != nil {
		log.Println("Can`t convert to sql")
		return err
	}

	if _, err = conn.Exec(context.Background(), query); err != nil {
		log.Printf("Can`t exec query: %s\n", query)
		return err
	}

	return nil
}
