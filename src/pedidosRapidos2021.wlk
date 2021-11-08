/**
 * 1    - pedido.precioBruto()
 * 2.i  - pedido.costoReal(cliente)
 * 2.ii - cliente.valorAAbonar(pedido) / pedido.valorAAbonar(cliente)
 * 3.i  - pedido.agregar(cantidad, producto) / pedido.agregar(item) 
 * 3.ii - cliente.realizarCompra(pedido) / pedido.realizarCompra(cliente)
 * 4    - cliente.compraMasCara()
 * 5    - cliente.montoTotalAhorrado()
 * 6.i  - cliente.productoMasCaro()
 * 6.ii - cliente.productoMasComprado()
 */
 
class Pedido {
	const local
	const items = #{}
	
	/** 1 */
	method precioBruto() = items.sum { item => item.precio() }
	
	/** 2.i */
	method costoReal(cliente) = 300.min(calculadorDeCuadras.cuadrasEntre(cliente, local) * 15)
	//method costoReal(cliente) = (calculadorDeCuadras.apply(cliente,local) * 15).min(300)
	
	/** 2.ii */
	//method valorAAbonar(cliente)
	
	/** 3.i */
	method agregar(cantidad, producto) {
		const item = items.findOrElse( { item => item.producto() == producto }, { self.crearItem(producto) } )
		item.aumentarCantidad(cantidad)
	}
	
	method crearItem(producto) { 
		const item = new Item(producto = producto)
		items.add(item)
		return item
	}
	
	method validarProductos() {
		if(not local.tieneProductos(items.map{ item => item.producto()}))
			throw new ProductosInvalidosException(message = "No hay producto")	
	}	
	
	method validarStock() {
		if(not local.tieneStock(items))
			throw new StockInvalidoException(message = "No hay stock")	
	}
}

class Local {
	const productos = #{}
	const items = #{}
	
	method tieneProductos(unosProductos) = unosProductos.all { producto => productos.contains(producto) }
	
	method tieneStock(itemsDelPedido) = 
		itemsDelPedido.all { 
			item => items.any{ stock => item.producto() == stock.producto() and item.cantidad() <= stock.cantidad() }
		}
}

class Item {
	const producto
	var cantidad = 0
	
	method precio() = producto.precio()	* cantidad
	
	method aumentarCantidad(unaCantidad) { cantidad += unaCantidad }
}

class Producto {
	const property precio
}

object calculadorDeCuadras {
	method cuadrasEntre(cliente, local) = 15
}
//const calculadorDeCuadras = { cliente, local  => 15 }

class Cliente {
	var property tipo = comun
	const compras
	
	/** 2.ii */
	method valorAAbonar(pedido) = pedido.costoReal(self) * tipo.factorDeEnvio(self)
	//method valorAAbonar(pedido) = tipo.valorAAbonar(pedido.costoReal(self), self)
	
	method cantidadDeCompras() = compras.size()
	
	/** 4 */
	method realizarCompra(pedido) {
		pedido.validarProducto()
		//pedido.validarStock()
		self.crearCompra(pedido)
	}
	
	method crearCompra(pedido) {
		const compra = new Compra(pedido = pedido, valorDeEnvio = self.valorAAbonar(pedido))
		compras.add(compra)
	}
}

class Compra {
	const pedido
	const valorDeEnvio
	const fecha = new Date()
}

object comun {
	method factorDeEnvio(cliente) = 1
	
	//alternativa
	method valorAAbonar(costo, cliente) = costo
}

object silver {
	method factorDeEnvio(cliente) = 0.5	
	
	//alternativa
	method valorAAbonar(costo, cliente) = costo / 2
}

object gold {
	method factorDeEnvio(cliente) = if(self.esQuintaCompra(cliente)) 0 else 0.1
			
	method esQuintaCompra(cliente) = cliente.cantidadDeCompras() % 5 == 0
		
	//alternativa
	method valorAAbonar(costo, cliente) = costo * self.factorDeEnvio(cliente)
}

