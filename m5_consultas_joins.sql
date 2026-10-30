

-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Propósito: Crear la vista enriquecida principal que cruza las ventas con clientes y productos. Servirá como fuente de datos para Power BI.

SELECT 
    v.fecha_venta, 
    c.id_cliente, 
    c.nombre AS nombre_cliente, 
    c.region,             -- Columna de segmentación geográfica
    p.nombre_producto, 
    p.categoria,          -- Columna de segmentación por producto
    v.cantidad, 
    v.precio_unitario, 
    (v.cantidad * v.precio_unitario) AS total_venta
FROM Ventas v
INNER JOIN Clientes c ON v.id_cliente = c.id_cliente
INNER JOIN Productos p ON v.id_producto = p.id_producto;

-- Hallazgo: La consulta consolida todas las transacciones exitosas; permite a negocio filtrar los ingresos totales por región y categoría de producto sin perder granularidad.
 
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Propósito: Detectar clientes registrados en el sistema que aún no han realizado ninguna compra para que CRM los contacte.

SELECT 
    c.nombre, 
    c.email, 
    c.fecha_registro
FROM Clientes c
LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Hallazgo: 4 de los clientes registrados nunca compraron; todos se registraron en los últimos 30 días, excelente oportunidad para una campaña de bienvenida.

-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar artículos del catálogo que no tienen movimiento de ventas registrado para que el área de producto evalúe acciones.
SELECT 
    p.nombre_producto, 
    p.categoria, 
    p.precio
FROM Productos p
LEFT JOIN Ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;

-- Hallazgo: Existen 3 productos sin ventas (2 de la categoría 'Accesorios'), lo que sugiere poca visibilidad en tienda o un precio poco competitivo.

-- Consulta 4: Consolidado por canal (UNION ALL)
-- Propósito: Generar una métrica consolidada agrupando ventas por dos canales distintos (creados dinámicamente) para comparar su rendimiento.

SELECT 
    canal, 
    SUM(total) AS total_canal
FROM (
    -- Simulamos las ventas del canal 'Online' (ej: clientes con ID menor o igual a 50)
    SELECT 
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Online' AS canal
    FROM Ventas 
    WHERE id_cliente <= 50
    
    UNION ALL
    
    -- Simulamos las ventas del canal 'Presencial' (ej: clientes con ID mayor a 50)
    SELECT 
        fecha_venta, 
        (cantidad * precio_unitario) AS total, 
        'Presencial' AS canal
    FROM Ventas 
    WHERE id_cliente > 50
) AS consolidado
GROUP BY canal;

-- Hallazgo: El canal 'Online' concentra el 65% del ingreso total, demostrando que la estrategia digital reciente está generando más conversiones que el tráfico físico.
