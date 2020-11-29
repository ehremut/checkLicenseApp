package db

import (
	"context"
	"fmt"
	"log"

	sq "github.com/Masterminds/squirrel"
	"github.com/jackc/pgx/v4/pgxpool"
)

// TODO: add custom error

const (
	userTable = "users"
	favoriteTable = "favorites"
)

type Database struct {
	pool *pgxpool.Pool
}

func NewDatabase(host string, port int) *Database {
	user, password := "postgres", "postgres"
	url := fmt.Sprintf("postgresql://%s:%s@%s:%d", user, password, host, port)
	pool, err := pgxpool.Connect(context.Background(), url)
	if err != nil {
		log.Fatalf("Unable to connection to database: %v\n", err)
	}

	return &Database{
		pool: pool,
	}
}

func (d *Database) GetUserPassword(ctx context.Context, login string) (string, error) {
	conn, err := d.pool.Acquire(context.Background())
	if err != nil {
		log.Printf("Unable to acquire a database connection: %v\n", err)
		return "", err
	}
	defer conn.Release()

	q := sq.Select("password").From(userTable).Where(sq.Eq{"login": login})
	queryString, _, err := q.ToSql()
	if err != nil {
		return "", err
	}

	rows, err := conn.Query(ctx, queryString)
	if err != nil {
		log.Printf("Error to scan password %s\n", err)
		return "", err
	}

	var password string
	for rows.Next() {
		err := rows.Scan(&password)
		if err != nil {
			log.Printf("Error to exec query %s\n", err)
			return "", err
		}
	}

	return password, nil
}
