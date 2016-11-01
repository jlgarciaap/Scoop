##PRACTICA MBAAS AZURE
No he tenido mucho tiempo para la práctica asi que he intentado ahorrarme tiempo en algunas cosas(antes de nada si no te funciona la api puede ser que me haya caducado la trial de Azure):

- He usado Storyboards por primera vez ya que me han parecido mas agiles para el conjunto, aunque debido a usarlos me ha surgido un problemas que no he sabido solucionar, al pinchar para ver el detalle de una noticia me sale como un viewController por defecto, en medio ¿me pudes ayudar? Creo que es porque estoy haciendo la llamada dos veces pero no he logrado resolverlo bien y de momento lo he dejado asi.

- En cuanto al uso de azure, he usado las easy tables y luego lhe modificado el script. Como tal el script es el de notices.js dentro de la carpeta de backend, los permisos y todo lo he gestionado desde azure, solo permitiendo leer a los no identificados.

- El script  de los jobs es el de changeState dento de la carpeta de backend. Al final se conecta a la base de datos y modifica un campo segun este otro y publicaria las noticias cambiadas una vez al dia.

- No le he dedicado mucho tiempo al tema visual(es bastante tristona la verdad), por si no se identifica bien en el detalle de las noticias tenemos un UIPicker para valorarlas del 1 al 5, te sale tambien la media de las valoraciones teniendo como maximo el 5.

- A la hora de editar una noticia todos son cambos editables el que peor se identifica es el textView para poner todos los detalles de las noticias, pero estar esta presente. 

- En cuanto al login lo he realizado con Google para probar otras opciones. Como se ve al usarla si te logas puedes hacer cosas si no solo ver lo publico y valorar. Se identifica al usuario por el id de google, asi que el campo Autor, el que se ve, solo es un poco de azucar para que se ponga lo que se quiera, realmente a la hora de ver las noticias, solo puedes ver las publicas y las que se identifiquen con tu ID de google. Mi idea era quitar el campo autor como rellenable y automaticamente poner el nombre de usuario de google(no el id megalargo que nos proporciona el currentuser.id). Creo que tengo el metodo para sacarlo pero no me ha dado tiempo.

- Muchas gracias me ha gustado bastante esta practica sobretodo por las posibilidades que tenemos mezclando todo, en dos dias he montado una app con mucha funcionalidad(y espero que aceptable jejejje)
