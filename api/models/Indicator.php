<?php
/**
 * Modelo Indicator - Catálogo de indicadores
 */

class Indicator {
    private $conn;
    private $table = 'indicators';

    public function __construct(PDO $db) {
        $this->conn = $db;
    }

    public function getAll(): array {
        $sql = "SELECT i.id, i.name, i.description, i.category, i.unit_id, i.direction, i.type, i.frequency, i.active, i.created_at,
                       u.name AS unit_name, u.symbol AS unit_symbol
                FROM {$this->table} i
                LEFT JOIN units u ON u.id = i.unit_id
                ORDER BY i.name";
        $stmt = $this->conn->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(int $id) {
        $sql = "SELECT i.id, i.name, i.description, i.category, i.unit_id, i.direction, i.type, i.frequency, i.active, i.created_at,
                       u.name AS unit_name, u.symbol AS unit_symbol
                FROM {$this->table} i
                LEFT JOIN units u ON u.id = i.unit_id
                WHERE i.id = :id";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':id', $id, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function create(array $data): bool {
        $sql = "INSERT INTO {$this->table}
                (name, description, category, unit_id, direction, type, frequency, active)
                VALUES (:name, :description, :category, :unit_id, :direction, :type, :frequency, :active)";
        $stmt = $this->conn->prepare($sql);
        $name = htmlspecialchars(strip_tags($data['name'] ?? ''));
        $description = htmlspecialchars(strip_tags($data['description'] ?? ''));
        $category = htmlspecialchars(strip_tags($data['category'] ?? 'general'));
        $unit_id = (int)($data['unit_id'] ?? 0);
        $direction = in_array(($data['direction'] ?? 'up'), ['up','down']) ? $data['direction'] : 'up';
        $type = in_array(($data['type'] ?? 'absolute'), ['absolute','relative']) ? $data['type'] : 'absolute';
        $frequency = in_array(($data['frequency'] ?? 'monthly'), ['monthly','quarterly','yearly']) ? $data['frequency'] : 'monthly';
        $active = isset($data['active']) ? (int)$data['active'] : 1;
        $stmt->bindParam(':name', $name);
        $stmt->bindParam(':description', $description);
        $stmt->bindParam(':category', $category);
        $stmt->bindParam(':unit_id', $unit_id, PDO::PARAM_INT);
        $stmt->bindParam(':direction', $direction);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':frequency', $frequency);
        $stmt->bindParam(':active', $active, PDO::PARAM_INT);
        return $stmt->execute();
    }

    public function update(int $id, array $data): bool {
        $fields = [];
        $params = [':id' => $id];
        foreach (['name','description','category','unit_id','direction','type','frequency','active'] as $field) {
            if (array_key_exists($field, $data)) {
                $fields[] = "$field = :$field";
                if ($field === 'unit_id' || $field === 'active') {
                    $params[":$field"] = (int)$data[$field];
                } else {
                    $params[":$field"] = htmlspecialchars(strip_tags($data[$field]));
                }
            }
        }
        if (empty($fields)) return false;
        $sql = "UPDATE {$this->table} SET " . implode(', ', $fields) . " WHERE id = :id";
        $stmt = $this->conn->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue($k, $v, ($k === ':unit_id' || $k === ':active') ? PDO::PARAM_INT : PDO::PARAM_STR);
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


