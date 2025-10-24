<?php
/**
 * Modelo Unit - Catálogo de unidades de medida
 */

class Unit {
    private $conn;
    private $table = 'units';

    public function __construct(PDO $db) {
        $this->conn = $db;
    }

    public function getAll(): array {
        $sql = "SELECT id, name, symbol, type, active, created_at FROM {$this->table} ORDER BY name";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(int $id) {
        $sql = "SELECT id, name, symbol, type, active, created_at FROM {$this->table} WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function create(array $data): bool {
        $sql = "INSERT INTO {$this->table} (name, symbol, type, active) VALUES (:name, :symbol, :type, :active)";
        $stmt = $this->conn->prepare($sql);
        $name = htmlspecialchars(strip_tags($data['name'] ?? ''));
        $symbol = htmlspecialchars(strip_tags($data['symbol'] ?? ''));
        $type = htmlspecialchars(strip_tags($data['type'] ?? ''));
        $active = isset($data['active']) ? (int)$data['active'] : 1;
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':symbol', $symbol);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':active', $active, PDO::PARAM_INT);
        return $stmt->execute();
    }

    public function update(int $id, array $data): bool {
        $fields = [];
        $params = [':id' => $id];
        foreach (['name', 'symbol', 'type', 'active'] as $field) {
            if (array_key_exists($field, $data)) {
                $fields[] = "$field = :$field";
                $params[":$field"] = $field === 'active' ? (int)$data[$field] : htmlspecialchars(strip_tags($data[$field]));
            }
        }
        if (empty($fields)) return false;
        $sql = "UPDATE {$this->table} SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, $k === ':active' ? PDO::PARAM_INT : PDO::PARAM_STR);
        }
        return $stmt->execute();
    }

    public function delete(int $id): bool {
        $sql = "DELETE FROM {$this->table} WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        return $stmt->execute();
    }
}
?>


